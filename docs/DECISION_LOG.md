# Datamoons Online - Decision Log

## Purpose

This document records important technical and design decisions so future work stays coherent.

It should be updated when a decision:

- changes implementation direction;
- creates a new default;
- replaces an older assumption;
- affects multiple repositories;
- impacts architecture, lore, combat, progression, or deployment.

---

## Entry Template

Use this format for new entries:

```md
## YYYY-MM-DD - Decision title

Status: accepted | superseded | deprecated | proposed

Context:
- Why this decision was needed.

Decision:
- What was chosen.

Impact:
- What changes because of it.

Repos affected:
- List repositories or docs.

Notes:
- Follow-ups, caveats, rollback notes, or migration reminders.
```

---

## 2026-07-03 - Godot 4.7 project baseline

Status: accepted

Context:
- The active Godot projects were updated away from the older 4.6 project feature marker.
- The local and VM workflows now rely on newer imports and metadata behavior.

Decision:
- Treat Godot 4.7 as the default project assumption in agent guidance and project metadata.

Impact:
- Agent and docs should prefer Godot 4.7-compatible solutions.
- VM and local environments should avoid mixing older editor/runtime assumptions with the active project files.

Repos affected:
- `datamoon-online-auth`
- `datamoon-online-client`
- `datamoon-online-gateway`
- `datamoon-online-server`
- `datamoon-online-agent`

Notes:
- Runtime versions may temporarily use release candidates during active testing, but documentation should clearly call out when that happens.

## 2026-07-03 - Production gameplay services track pbe

Status: accepted

Context:
- The active development and deployment work was aligned around the `pbe` branch for gameplay services.

Decision:
- Use `pbe` as the active branch for:
  - `datamoon-online-auth`
  - `datamoon-online-gateway`
  - `datamoon-online-mysqlapi`
  - `datamoon-online-server`

Impact:
- Deployment instructions and operational checks should assume those repos run from `pbe` unless explicitly stated otherwise.

Repos affected:
- `datamoon-online-auth`
- `datamoon-online-gateway`
- `datamoon-online-mysqlapi`
- `datamoon-online-server`

Notes:
- `datamoon-online-web` remains on `main`.
- `datamoon-online-client` may be developed locally on `pbe`, but it is not a VM runtime service.

## 2026-07-03 - Public client connection target updated to new VM

Status: accepted

Context:
- The public VM IP changed during the beta environment update.

Decision:
- Point the client network host defaults and project settings to `18.209.238.32`.

Impact:
- Local client tests now target the new VM without requiring manual per-run edits.

Repos affected:
- `datamoon-online-client`

Notes:
- Internal service-to-service communication on the VM continues to use loopback where appropriate.

## 2026-07-03 - Beta web service may remain disabled

Status: accepted

Context:
- During beta iteration, the web service is not required for the core gameplay stack.

Decision:
- It is acceptable to keep `datamoon-web.service` disabled and stopped until the beta web surface is needed again.

Impact:
- Operational focus remains on:
  - `datamoon-api`
  - `datamoon-auth`
  - `datamoon-gateway`
  - `datamoon-server`

Repos affected:
- `datamoon-online-web`
- deployment and operations docs

Notes:
- If the web surface becomes part of a live beta flow, this decision should be revisited.

## 2026-07-03 - Auth, gateway, and server runtime aligned to Godot 4.7.1 rc1 on VM

Status: accepted

Context:
- Local development was already using Godot 4.7.1 rc1.
- VM parity was needed to reduce runtime mismatch between local testing and deployed services.

Decision:
- Run `datamoon-auth`, `datamoon-gateway`, and `datamoon-server` on the VM with Godot `4.7.1 rc1`.

Impact:
- Local and VM behavior should be closer during beta iteration.
- Release-candidate risk is knowingly accepted for this phase.

Repos affected:
- `datamoon-online-auth`
- `datamoon-online-gateway`
- `datamoon-online-server`

Notes:
- This should be revisited once a stable patch release is available and validated.

## 2026-07-06 - Evolution system v1 baseline

Status: accepted

Context:
- The team defined the first gameplay and persistence rules for Datamoon evolutions before runtime implementation.
- Nocmoon was selected as the first official evolution line to anchor the system.

Decision:
- Persist evolution unlocks by `datamoon_id`, not by character.
- Do not persist the currently active evolved form in v1; the Datamoon returns to its base `Code` form on login.
- Death also forces regression to the base `Code` form.
- Unlock progression is sequential inside a line: a later form cannot be unlocked if the previous form in the same line is still locked.
- Transformation is allowed anywhere, but not while the Datamoon is in action.
- Unlock consumes items only once, at unlock time.
- Transforming refills HP/MP, preserves buffs, and resets skill cooldowns.
- The first official line is `Nocmoon -> Kainemoon -> Bathorymoon`.

Impact:
- The mysqlapi should store unlock rows keyed by Datamoon instance.
- Server runtime should treat form state as temporary session state and unlock state as persistent progression.
- UI should expose `locked`, `unlockable`, `unlocked`, and `active` states for each form.
- Catalog validation should enforce previous-stage unlock requirements before allowing later-stage unlocks.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-client`
- `datamoon-online-mysqlapi`
- `datamoon-online-server`

## 2026-08-03 - Species enemy AI and spawn-group reactions

Status: accepted

Decision:
- Enemy personality is selected by registered `ai_behavior`, not by the former
  generic aggressive/passive behavior switch.
- Runtime alarms belong to `space_id + area_id`; dungeon instances cannot share
  targets or group state.
- Slimmoon groups panic together after damage. Nocmoon groups acquire territorial
  aggro together after detection or damage.
- Lifecycle, group state, AI decisions and action animation states are separate.
  Spawn and death block combat in both directions.
- Behaviors return intentions only. Shared components own perception, movement,
  combat selection and lifecycle, while the existing action FSM owns impact
  timing.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-client`
- `datamoon-online-server`

## 2026-08-03 - Allied spawn presentation and opaque death

Status: accepted

Decision:
- Allied Datamoons appear directly in `ACTIVE` on login. Recovery from death,
  portal entry and worker handoff entry use their Spawn animation.
- Enemy spawn lifecycle remains unchanged and continues to block combat.
- Death presentation uses the authored animation without changing sprite
  opacity.
- Flee destination retention is spawn-data-driven so coward species can change
  course less abruptly without changing their movement speed.

Repos affected:
- `datamoon-online-client`
- `datamoon-online-server`
- `datamoon-online-agent`

## 2026-08-04 - Allied login position follows character authority

Status: accepted

Decision:
- On a normal login, the active allied Datamoon starts at the character's
  resolved safe login position instead of restoring its separately persisted
  follower coordinate.
- The Datamoon coordinate remains persistable for checkpoints and handoffs, but
  it is not an independent login anchor because the active companion belongs to
  the character's movement session.
- Portal and worker handoff flows continue to place both entities through the
  authoritative transition destination and keep their existing Spawn lifecycle.

Reason:
- A follower coordinate can lag behind the character or resolve against stale
  world collision. Making it the first direct-control origin caused repeated
  reconciliation pulls until control had been cycled once.

Repos affected:
- `datamoon-online-server`
- `datamoon-online-agent`

## 2026-08-04 - Enemy death is independent from reward eligibility

Status: accepted

Decision:
- An enemy that reaches zero HP always enters its Death lifecycle and is
  removed normally, even when no eligible attacker remains online.
- Reward eligibility controls only reward and quest-credit delivery. It must
  never restore enemy HP or call the spawn reset path as a fallback.
- Disconnecting a character removes its entries from live enemy damage ledgers.
  If that character owned first-hit attribution, the earliest remaining hit
  becomes first hit.

Reason:
- Runtime death is authoritative combat state, while rewards are an optional
  consequence. Coupling both allowed stale disconnected-session attribution to
  revive an enemy at full HP when a later damage source completed the kill.

Repos affected:
- `datamoon-online-server`
- `datamoon-online-agent`

## 2026-07-31 - Two-step authenticated credential changes

Status: accepted

Decision:
- Registration and unauthenticated password recovery continue to use single-use
  links sent to the account e-mail.
- Authenticated password changes require the current password and a six-digit
  code sent to the current e-mail.
- E-mail changes require the current password, a six-digit code sent to the old
  address and a single-use confirmation link sent to the new address.
- Codes expire after 10 minutes, allow five attempts and are stored only as
  SHA-256 hashes. Pending passwords are stored only as bcrypt hashes.
- Completing a password or e-mail change increments `credential_version` and
  revokes existing account sessions.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-mysqlapi`
- `datamoon-online-web`

## 2026-08-06 - Public Moonpedia catalog

Status: accepted

Decision:
- The public Datamoon encyclopedia is named Moonpedia and uses dynamic pages at
  `/moonpedia/{sprite}`.
- Canonical stats and skills remain in the Server Datamoon JSON files. The MySQL
  API embeds a synchronized read-only copy and exposes sanitized data only to
  the Web service.
- Moonpedia numbering follows the insertion order of `datamoon_types.json`.
  Per-Datamoon metadata records that stable position, while `enabled` controls
  whether an entry is public. Missing art therefore does not renumber entries.
- The Web renders base stats, per-level increments, levels 50 and 100, plus
  skill base power by skill level. Runtime combat modifiers are explicitly not
  presented as guaranteed final damage.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-mysqlapi`
- `datamoon-online-server`
- `datamoon-online-web`

## 2026-07-27 - Global active quest log and level-interval rewards

Status: accepted

Decision:
- The global Quest Log lists only accepted quests with `active` or
  `ready_to_turn_in` status and shows objective progress from the authoritative
  quest snapshot.
- Accepting, talking through and turning in quests remain bound to the configured
  NPC and proximity checks. Abandoning an owned active quest is available from
  the global log and resets its objective rows.
- An authored reward written as level `A -> B` means level `A` is the quest
  requirement and the Datamoon XP reward is the cumulative XP from the start of
  level `A` to the start of level `B`.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-client`
- `datamoon-online-server`

## 2026-08-03 - Persistent world location

Status: accepted

Decision:
- Character location persistence stores `space_id`, `posx` and `posy` as one
  authoritative location. A normal reconnect restores the same registered
  overworld map and coordinates.
- Runtime dungeon instance IDs are never durable character locations. Dungeon
  entry, checkpoints and disconnects persist the registered overworld return
  map and position instead.
- Missing, removed or invalid map IDs fall back to `digital_center` at its safe
  default position rather than exposing an unloadable space to the Client.
- Login activates an allied Datamoon directly without Spawn. Recovery from
  death and completed portal/worker handoff loading continue to use Spawn;
  death in a registered overworld map keeps that map.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-mysqlapi`
- `datamoon-online-server`

## 2026-08-04 - One-shot space readiness

Status: accepted

Decision:
- A same-worker map transition creates one server-owned pending readiness record
  containing the expected `space_id` and a 30-second deadline.
- The first matching Client acknowledgement consumes that record before the
  allied Spawn lifecycle starts. Unsolicited, mismatched and replayed readiness
  messages cannot restart Spawn or disable combat collisions.
- Failure to acknowledge before the deadline disconnects the peer rather than
  leaving an invulnerable entity in the world.
- Teleports that remain in the same `space_id` start their timed Spawn directly;
  they never wait for a scene-loading acknowledgement that the Client will not
  emit.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-server`

## 2026-08-04 - Enemy navigation, evade and non-blocking death

Status: accepted

Decision:
- Enemy movement requires `NavigationAgent2D` and synchronized authoritative map
  navigation. Repath is adaptive by activity, jittered across frames and capped
  at 16 new paths per worker physics frame. Calm enemies outside a 1024-pixel
  player radius suspend AI and recheck through the chunk index at a distributed
  interval. Missing navigation halts the enemy and reports a configuration
  error; direct steering is not a rollout fallback.
- Godot avoidance is disabled by default; species separation remains explicit
  and bounded so pathfinding does not introduce an all-agent CPU cost.
- Hard-leash return clears group threat and enters one second of authoritative
  Evade after restoring the enemy at home with full HP/MP.
- Death lifecycle, worldstate removal and respawn scheduling never wait for the
  persistence API. Reward delivery remains idempotent, and the hidden enemy node
  is retained only while that asynchronous operation resolves.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-server`

## 2026-08-04 - Same-worker short session resume

Status: implemented; manual validation pending

Decision:
- An unexpected gameplay disconnect preserves the authoritative character,
  Datamoon, Party and dungeon membership for 30 seconds on the same worker.
- A rotating opaque token is held only in memory, has a 60-second rolling TTL,
  is claimed atomically and consumed once. Login tickets are never reused.
- The disconnected entity is stopped but remains vulnerable. A successful
  rebind changes the control epoch and sends a fresh world baseline plus
  inventory, equipment, HUD, social, dungeon and cooldown snapshots.
- Explicit logout, handoff, durable lease loss, timeout and worker shutdown use
  definitive cleanup. Worker crash recovery remains outside this feature.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-client`
- `datamoon-online-server`

## 2026-07-25 - Hybrid world labels and quest completion contracts

Status: accepted

Decision:
- World-name labels keep canonical editor values so authored scenes preview the
  runtime result: nickname size 24, guild size 22, outline 6, shadow outline 4
  and visual scale 0.5.
- `Entity` reapplies the same values at runtime as a compatibility safeguard for
  inherited, dynamic and legacy scenes. Semantic colors and scene-specific
  positions remain authored per entity.
- Dialogue quests stay active until the player reaches the final dialogue
  balloon and explicitly selects `Complete`.
- Closing the UI, leaving NPC range, disconnecting or changing NPC cancels the
  temporary dialogue session without advancing the quest.
- Dungeon quest credit occurs only after daily completion is accepted and the
  dungeon reward operation succeeds. Matching automatic quests then complete
  through a server-authoritative, idempotent event.

Implementation status:
- Hybrid world-label presentation is implemented in the Client scenes and
  runtime base class.
- Dialogue completion/cancellation and dungeon objective hooks are implemented
  in the current Server/API/Client flow.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-client`
- future Server, MySQL API and Client quest implementation

## 2026-07-25 - Deterministic combat and source-scaled effects

Status: accepted

Decision:
- Basic attacks use effective ATK as their power. Skills retain independent,
  data-driven formulas and do not implicitly fall back to ATK.
- Damage no longer uses random variance or a level-difference multiplier.
  Positive post-formula damage has a minimum result of one.
- Critical chance remains a separate probabilistic basic-attack mechanic.
- Bleed, Poison and Burn scale from a percentage of the source's effective ATK
  captured when the effect is applied.
- Runtime stat changes do not alter an existing DOT. Concurrent applications
  deal only the strongest captured tick instead of summing every application,
  and equal or weaker renewals cannot replace or extend the strongest value.
- Skills may define server-authoritative conditional post-hit effects, beginning
  with target-effect checks and self-healing proportional to actual damage.

Notes:
- Nocmoon's existing Bleed is represented as 10% effective ATK per tick.
- Nocmoon's conditional healing percentage remains intentionally unset until
  species balance is finalized.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-server`

Notes:
- Multi-line branching is still planned, but the first implementation target is a single linear line for Nocmoon.
- Switching between different lines must require regression to `Code`.

## 2026-07-23 - Full-stack audit hardening baseline

Status: accepted

Context:
- A cross-repository audit followed authentication, connection, gameplay,
  persistence, handoff, performance and dead-code paths.
- Public credential transport and committed secrets were identified as the
  highest operational risks.

Decision:
- Keep Gateway routing-only, Server gameplay-authoritative and MySQL API as the
  sole persistence boundary.
- Require strict internal HTTP authentication/parsing, strengthen Gateway login
  throttling and remove the obsolete Auth port 5300 listener.
- Treat encrypted public transport, secret rotation, private service listeners
  and per-service API identities as release-priority work.

Impact:
- Canonical architecture now records trust boundaries and actual login,
  gameplay and handoff flows.
- Current evidence and release gates live in `docs/CODE_HEALTH.md` and
  `docs/FIRST_BETA_ROADMAP.md`.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-auth`
- `datamoon-online-gateway`
- `datamoon-online-mysqlapi`
- `datamoon-online-server`

## 2026-07-23 - Secure login transport and centralized documentation

Status: accepted

Decision:
- Public login/registration uses certificate-validated WebSocket TLS; gameplay
  remains on ENet.
- Internal API access is scoped to Auth, Gateway, Server or Web with separate
  tokens and route-level permissions.
- Auth and API default to loopback-only listeners.
- Project documentation lives in `datamoon-online-agent`; repository-local
  `AGENTS.md` files are mandatory pointers to the canonical index.
- Third-party licenses and asset READMEs remain with their assets.
- VM updates use the coordinated preflight/build/restart/rollback script.

## 2026-07-23 - Manual functional validation

Status: accepted

Decision:
- Automated functional/regression test files are removed from runtime repositories.
- PBE behavior is validated manually through real Client/Gateway/Auth/API/worker flows.
- Structured logs expose transitions, outcomes and correlation identifiers without credentials or tickets.
- CI and deploy retain import, formatting, static analysis, syntax and build checks.

## 2026-07-24 - Generated equipment progression contract

Status: accepted

Decision:
- Bracelet, Hood and Shoes generate exactly three stat entries from capped,
  weighted pools; a stat may repeat only up to its equipment-specific cap.
- Equipment enters through `[UNSCAN]` box items and generation is authoritative,
  transactional, idempotent and audited.
- Equipment bonuses belong to the character loadout and apply to the active
  Datamoon. Equipment changes are blocked in combat and recalculate immediately
  outside combat.
- Upgrade progression stops at `+5`, uses target-level chances of 100%, 90%, 80%,
  70% and 60%, and Alternate Chip replaces one player-selected stat entry with a
  server-generated eligible result.
- The current dungeon grants one Upgrade Chip and has a 5% chance to grant one
  Alternate Chip on eligible completion.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-client`
- `datamoon-online-server`
- `datamoon-online-mysqlapi`

Notes:
- Every attempt consumes one chip; failure never destroys or downgrades equipment.

## 2026-07-28 - Archive activation and safe interaction combat rules

Status: accepted

Decision:
- Activating a Datamoon through the Archive restores HP to the active
  equipment-adjusted maximum.
- The restored HP is persisted before the Archive swap is confirmed. A failed
  persistence attempt rolls the active selection and runtime Datamoon back to
  the previous state.
- Archive, NPC, and portal interactions are unavailable while the active
  Datamoon is in combat.
- Archive activation immediately refreshes quest eligibility and NPC quest
  indicators for the newly active Datamoon.
- Equipment NPC slots reference inventory rows through left-click and do not
  move the underlying item.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-client`
- `datamoon-online-server`
- Common stats use weight 10 and Crit/Skill Damage use weight 3.
- Equipment has no rarity or quality; Critical Damage and Attack Speed are future
  stats.

## 2026-07-24 - Chat moderation and party lifecycle scope

Status: accepted

Decision:
- Chat moderation uses account-level administrators, with authority inherited by
  every character on the account.
- Supported staff controls are mute/unmute and persistent channel slow/normal
  mode. Chat-ban and message reports are not part of this scope.
- Administrative command syntax and usage feedback are not exposed to normal
  accounts. The MySQL API still re-authorizes every valid staff mutation.
- The fifth message in two seconds is blocked and applies a 2,000 ms timeout.
- Moderation expiry is stored in UTC with millisecond precision and blocked sends
  show remaining seconds to the player.
- Definitive offline state removes party membership; worker handoff preserves it.
  Remote-worker members remain gray in the HUD without an `OFFLINE` label.

Notes:
- Implemented in PBE with account admin identity, in-game commands,
  millisecond-expiry persistence and automatic timeout audit.

## 2026-07-24 - Data-driven dungeon selection and equipment presentation

Status: accepted

Decision:
- Dungeon Concourse portals remain Server-instantiated from the shared portal
  scene and world JSON; their Client selection shell is an authored `.tscn`.
- Dungeon templates have no overworld `entry_portal`. Selection stores the
  portal's safe adjacent `return_position` as the return destination, while
  `exit_portal` remains per-instance runtime content.
- Generated equipment boxes use `guaranteed_rewards` with the registered
  `equipment_stats` metadata generator instead of a parallel `unscan_result`.
- Equipment stat curves and upgrade chances are catalog data. Item descriptions
  and new player-facing UI/feedback strings use Client language keys.
- Upgrade and Alternate live in a dedicated NPC terminal. Its UI slots hold
  disposable inventory row references only; operations lock the selected
  equipment and exact material stack transactionally, and equipped targets are
  rejected by the backend.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-client`
- `datamoon-online-mysqlapi`
- `datamoon-online-server`

## 2026-08-04 - Data-driven enemy alerts and soft leash

Status: accepted

Decision:
- Enemy behavior remains Server-authoritative and hybrid: reusable components
  in scenes, tuning in JSON profiles, runtime decisions in scripts.
- Slimmoon panic is individual; Nocmoon territorial aggro remains group-scoped.
- One returning member cannot clear the alert of an entire spawn group.
- Spawn radius and wander range are independent. Exiting the soft range steers
  inward; only hard-leash recovery may reset resources.
- Path stalls repath first. Emergency snap is an eight-second safety fallback
  with structured warning and metrics.
- Calm sleeping enemies stop unnecessary physics movement, while active
  wander/chase uses cached lightweight separation instead of global avoidance.
- Final obstacle-aware navigation polygons remain map-authoring work.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-server`

## 2026-08-05 - First-party account support desk

Status: accepted

Decision:
- Support is an authenticated first-party portal backed by scoped MySQL API
  operations, not generic database access or inbound SES processing.
- Players can access only their own tickets. Account-level `is_admin` grants the
  administrative queue and state controls.
- SES sends event notifications containing a portal link; replies remain inside
  the authenticated site. Attachments and public anonymous tickets are deferred.
- Ticket content is persistent operational data but is never duplicated into
  journald or generic audit metadata. State changes have a separate event trail.
- Web pages remain server-rendered. Domain CSS is modular in source and bundled
  into one response; JavaScript is added only for interactions that require it.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-mysqlapi`
- `datamoon-online-web`

## 2026-08-07 - Client-authored maps and reduced server geometry

Status: accepted

Decision:
- Each playable space has a visual Client scene and a corresponding
  authoritative Server scene in the same world coordinate system.
- Artists author terrain, decoration and dense forest patterns in the Client.
  The Server receives only simplified blockers, navigation, markers and
  interactive authoritative objects.
- Dense background vegetation stays outside Y-sort. Nearby reusable tree scenes
  share Y-sort with world entities and use an origin at the trunk base.
- Blocking TileMap cells are exported, merged and simplified into Server
  polygons. Copying one physics body per decorative 16-pixel tile is rejected
  for maintainability and runtime cost.
- Moonlight Forest's current 256-by-128 visual layout is an initial composition,
  not final authoritative navigation. Server geometry will be generated after
  its blocking layout stabilizes.

Repos affected:
- `datamoon-online-agent`
- `datamoon-online-client`
- `datamoon-online-server`
