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

Group states are `CALM`, `PANIC`, `AGGRO` and `COOLDOWN`. Group state belongs to
one `space_id + area_id`, so dungeon instances never share alarms.

AI decisions are `HOLD`, `WANDER`, `CHASE`, `FLEE` and `RETURN_HOME`. The action
FSM remains independent and contains `Idle`, `Move`, `Attack`, `Skill`, `Spawn`
and `Death`.

## Current Personalities

### Slimmoon

- Calm Slimmoons wander and ignore nearby players.
- Damage to any member activates `PANIC` for the whole spawn group.
- Every member continuously flees from the attacking Datamoon while the target
  remains inside `engagement_radius`.
- Each member keeps an individual short-lived flee target with angular/radial
  variation and local separation, preventing the group from stacking at one
  point while remaining inside the authored home circle.
- New members finish spawn and inherit an active panic.
- The group enters cooldown outside engagement range and calms after
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
  "spawn_pos": [0, 0],
  "radius": 96,
  "engagement_radius": 160,
  "reset_distance": 320,
  "calm_delay": 3.0,
  "move_speed": 80,
  "flee_retarget_min_seconds": 1.2,
  "flee_retarget_max_seconds": 1.8,
  "max_mobs": 5
}
```

- `radius`: circular spawn and wander region.
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
- Reward contribution and combat threat are separate concepts.
- Add new decisions/components when a capability is reusable; do not grow a
  species script into a second `DatamoonEnemy`.
