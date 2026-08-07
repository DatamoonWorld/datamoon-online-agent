# Datamoons Online - Enemy AI

## Purpose

Enemy AI is server-authoritative and expresses each species personality without
duplicating perception, movement, combat timing, leash, spawn or death code.

## Architecture

```text
EnemySpawner
  -> EnemySpawnGroup per space_id + area_id

DatamoonEnemy
  -> EnemyBrain
     -> Species EnemyBehavior
     -> EnemyCombatController
     -> EnemyLifecycle
  -> Action StateMachine
     -> Idle / Move / Attack / Skill / Spawn / Death
```

`DatamoonEnemy` owns entity stats, combat surfaces, damage ledger and rewards.
`EnemyBrain` turns species decisions into movement intentions. Behaviors never
deal damage directly. `EnemyCombatController` chooses skill, basic attack or
approach, while the existing action FSM owns animation timing and impact windows.
Movement requires a reusable `NavigationAgent2D` and synchronized authoritative
navigation regions. Repath cadence is adaptive: 100-180 ms for close pursuit,
250-400 ms for distant pursuit, 150-250 ms while fleeing, 200-300 ms while
returning, and 750-1000 ms while wandering. Jitter distributes work across
frames, and the worker admits at most 16 new paths per physics frame. Avoidance
remains disabled by default to bound CPU cost. Missing navigation halts the
enemy and reports one configuration error instead of silently using direct
steering.

Calm enemies with no player Datamoon within 1024 pixels suspend perception,
decisions and pathfinding. They recheck through the world chunk index every
750-1250 ms. Sleeping enemies no longer call `move_and_slide()` after their
velocity is already zero. Active enemies still move every physics tick; only
path creation and local separation sampling are rate-limited.
Prometheus exposes `enemy_navigation_paths_total`,
`enemy_navigation_budget_deferred_total`, `enemy_ai_sleep_total`, and
`enemy_ai_wake_total` for capacity validation.

## State Layers

Lifecycle phases are `SPAWNING`, `ACTIVE`, `DYING` and `DESPAWNING`. Combat is
blocked in every phase except `ACTIVE`; hitbox, hurtbox and body collision are
disabled during spawn/death.

Allied Datamoons use a smaller `DatamoonPetLifecycle` with `SPAWNING`, `ACTIVE`
and `DYING`. Login activates the companion directly; return from death and
completed portal/handoff loading use Spawn. The server blocks movement and
bilateral combat for the authored timing, while the client only presents the
replicated state. Species with zero-frame lifecycle timing transition
immediately.

Alert states are `CALM`, `PANIC`, `AGGRO` and `COOLDOWN`. An AI profile declares
`alert_scope` as `individual` or `group`. Group state belongs to one
`space_id + area_id`, so dungeon instances never share alarms. A returning
member never clears the alert of unrelated members.

AI decisions are `HOLD`, `WANDER`, `CHASE`, `FLEE` and `RETURN_HOME`. The action
FSM remains independent and contains `Idle`, `Move`, `Attack`, `Skill`, `Spawn`
and `Death`.

Crossing only the soft wander boundary steers the enemy back through navigation
without healing or teleporting. Crossing the hard leash enters an internal
Evade phase. The enemy returns home with full resources, remains unable to deal
or receive damage for one second, and then immediately selects a wander target.
Path stalls request a new path; an emergency snap is allowed only after the
profile timeout and emits a counter plus structured warning.

## Current Personalities

### Slimmoon

- Calm Slimmoons wander and ignore nearby players.
- Damage activates `PANIC` only for the attacked Slimmoon.
- The attacked member flees while the target remains inside
  `engagement_radius`; nearby Slimmoons keep their own state.
- Each member keeps an individual short-lived flee target with angular/radial
  variation and local separation, preventing the group from stacking at one
  point while remaining inside the authored home circle.
- The preferred flee radius and orbit side are selected once per panic. Repath
  updates preserve them so an enemy cannot alternate between inward and
  tangential movement at the home boundary.
- The individual alert enters cooldown outside engagement range and calms after
  `calm_delay`.
- Flee targets are constrained to the authored home circle; `reset_distance` is
  only the hard safety leash.

### Nocmoon

- Calm Nocmoons wander and scan using the scene-authored `AwarenessArea`.
- Detection or damage activates `AGGRO` for the whole spawn group.
- Every member pursues the same active Datamoon and independently selects a
  valid skill/basic attack based on range and cooldown.
- New members finish spawn and inherit active aggro.
- Leaving `engagement_radius` starts cooldown; after `calm_delay`, the group
  clears its target and returns home.

## Spawn Configuration

```json
{
  "id": "species_area_id",
  "type": "SpeciesName",
  "ai_behavior": "species_behavior_id",
  "ai_profile": "species_behavior_id",
  "spawn_pos": [0, 0],
  "radius": 96,
  "wander_range": 160,
  "engagement_radius": 160,
  "reset_distance": 320,
  "calm_delay": 3.0,
  "move_speed": 80,
  "flee_retarget_min_seconds": 1.2,
  "flee_retarget_max_seconds": 1.8,
  "max_mobs": 5
}
```

- `radius`: circular spawn distribution only.
- `wander_range`: soft roaming boundary. It may be larger than the spawn radius.
- `AwarenessArea`: natural detection radius authored in the enemy scene.
- `engagement_radius`: distance from the area center that retains group alarm.
- `reset_distance`: absolute hard leash; it must be at least the engagement
  radius.
- `calm_delay`: hysteresis before clearing an alarm after the target leaves.
- `flee_retarget_min_seconds` and `flee_retarget_max_seconds`: optional interval
  during which a fleeing enemy keeps its individual destination before choosing
  another one. Longer intervals produce less abrupt path changes.
- `ai_behavior`: registered personality. Unknown ids use the defensive fallback
  and emit a server warning.
- `ai_profile`: entry in `enemy_ai_profiles.json`; defaults to `ai_behavior`.
  Per-area `ai` values override that profile.

AI profiles own alert scope, perception cadence, return watchdogs, emergency
timeout, evade time, sleep checks, soft-boundary ratios, flee steering and
lightweight movement separation. Values remain data-driven without duplicating
species behavior code.

## Adding A New Species AI

1. Create `utils/scripts/enemy_ai/<species>_behavior.gd` extending
   `EnemyBehavior`.
2. Override only the required hooks: `wants_natural_perception()`,
   `on_target_detected()`, `on_damaged()` and `decide()`.
3. Return `EnemyAIDecision`; never move, damage or mutate cooldowns directly in
   the behavior.
4. Register the id in `EnemyBehaviorRegistry`.
5. Create the normal Datamoon scene and an enemy scene inheriting it. Add the
   reusable `enemy_brain.tscn`, `AwarenessArea`, `Spawn` and `Death` FSM nodes.
6. Set `ai_behavior` and group tuning in every spawn/dungeon definition.
7. Define `combat_timing.spawn` and `combat_timing.death` in the species JSON.
   A zero-frame timing activates or removes immediately.
8. Validate calm behavior, group trigger, respawn inheritance, engagement exit,
   hard leash, blocked spawn/death combat and dungeon instance isolation.

## Rules

- The client only presents replicated state; it never decides AI or damage.
- Group runtime state is transient and must not be persisted in MySQL.
- Use `worldstate.get_datamoons_near()` for bounded perception.
- Behavior scripts must remain stateless; mutable runtime state belongs to the
  brain or spawn group.
- Use individual alerts for isolated reactions and group alerts only when the
  species design explicitly calls for social aggro.
- Reward contribution and combat threat are separate concepts.
- Death presentation and world removal follow authored lifecycle time and never
  wait for reward persistence. The hidden entity remains alive only until its
  idempotent reward operation finishes.
- Add new decisions/components when a capability is reusable; do not grow a
  species script into a second `DatamoonEnemy`.

## Map Navigation Authoring

The authoritative server map is split into one scene per playable space under
`datamoon-online-server/scenes/maps/`. `main_map.tscn` remains the runtime root
for shared entity containers and legacy TileMap compatibility, while each map
scene owns its navigation regions and new static collision objects.

- Add map-specific navigation only to that map's `Navigation` node.
- Add non-interactive blockers such as trees, rocks, and walls below
  `StaticObjects`; do not register them as synchronized world objects.
- Keep the client sprite and server collision at the same world position.
- Use a world object only when the object has gameplay state or interaction
  that clients must receive from the server.

### Adding a server map

1. Create a scene named after the playable space in both client and server
   `scenes/maps/` directories.
2. Keep visual TileMap layers, decoration, lighting and sprites in the client
   scene. Keep navigation, collision and authoritative blockers in the server
   scene.
3. Give the server scene `Navigation` and `StaticObjects` children, then
   instance it below `MainMap/Maps` without changing its world coordinates.
4. Assign navigation layers that match the spawn-area configuration and verify
   wander, flee, chase and return behavior against the final collision layout.
5. Place ordinary scenery collision below `StaticObjects`. Create a synchronized
   world object only for stateful or interactive content such as portals,
   harvestables or destructible props.

The shared `MainMap` TileMap is a compatibility layer for existing collision
and fishing queries. Migrate its content into the matching map scene only when
all consumers of the shared TileMap have been updated; do not duplicate active
collision during migration.

- Prefer navigation polygons authored in the map TileSet for ordinary world
  tiles, or a `NavigationRegion2D` for irregular walkable geometry.
- Bake only walkable ground and exclude walls, props and portal blockers.
- Keep navigation regions in the same world as the authoritative enemy nodes.
- Validate narrow passages with the largest enemy collision radius used there.
- Navigation data is map content: visual map work must validate that chase,
  flee, wander and return paths do not cross blocked tiles.
- The placeholder Moonlight Forest uses small authored navigation regions for
  each current spawn group. Their layer and bounds are declared by spawn data;
  targets outside a group's temporary region cancel aggro instead of pulling
  enemies into map walls. Replace these provisional rectangles with authored
  collision-aware polygons when the final map is ready.
- A new map is incomplete until its authoritative navigation region is present;
  enemies deliberately stop and report a configuration error without one.

Set `EnemyBrain.debug_draw` only in a local graphical Server run to display the
soft wander boundary, hard leash and current navigation target. Keep it disabled
in headless workers.
