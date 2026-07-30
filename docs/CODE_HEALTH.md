# Code Health And Domain Review

> This is a technical review snapshot, not an active backlog. Current gameplay
> status and priorities live only in `FIRST_BETA_ROADMAP.md`.

Last focused gameplay pass: 2026-07-24. Scope: approximately 45,000 code lines across
Auth, Gateway, Server, Client, MySQL API and Web.

Latest cross-repository pass: 2026-07-30. The checklist below is the canonical
code cleanup tracker. A checked item means it was verified or safely completed;
unchecked items require an isolated change and manual validation before removal.

## Overall Assessment

Authority boundaries and persistent consistency are cohesive. Size is not itself
the main problem; concentrated responsibilities and duplicated orchestration are.
Refactoring must preserve RPC/API contracts, operation IDs, leases and gameplay
rules rather than optimize only for line count.

## Highest-value Reductions

### Recipe Activities

Crafting and Cooking now share reusable recipe activity infrastructure while
retaining thin domain facades for RPC/UI semantics. Future recipes should extend
the shared engine instead of restoring duplicated catalog and result handling.

### Social Runtime

Party and Guild now use a shared social directory for online-character and client
resolution. Their leadership, persistence, reward-sharing and dungeon-binding
rules remain separate. A dedicated relay/pub-sub adapter is still a future scale
improvement; database relay remains acceptable for PBE.

### Inventory And Rewards

Inventory operation context has been extracted and persistent mutations retain
the MySQL API transaction as the atomic boundary. Item use, generated equipment,
upgrade and alternate operations should move into focused services rather than
expanding the inventory facade again.

The Equipment NPC keeps non-owning UI selections: clicking a selected NPC slot
clears it without moving inventory, and material quantities are displayed as the
sum of every matching inventory stack. Consumption remains atomic against a
concrete row; the Client selects the next matching stack when one is exhausted.

### Dungeon And Portals

Portal and dungeon content parsing/normalization now lives in `portal_config.gd`.
`portal_manager.gd` remains the public facade for local instances, remote handoff,
completion, rewards and timeout/ejection. Instance lifecycle and transfer
orchestration are the next safe extraction boundaries.

## Domain Findings

### Combat

Damage authority, target/space validation, action acknowledgements and projectile
de-duplication are cohesive. Improve by moving formulas into immutable typed
combat inputs/results and separating action lifecycle from damage math. Validate
defense curves, level gaps, systems, buffs, AoE cadence and simultaneous death
through controlled live scenarios with structured inputs/results in logs. Avoid
adding more logic to `combat.gd` before this split.

### Guild

Persistent membership and role operations belong in the API and snapshots are
server-distributed, which is correct. Permission matrices are centralized,
invites expire, and persistent Guild audit records cover administrative state
changes. Query/admin presentation remains future tooling.
Cross-worker chat works through persistence polling but should eventually use a
dedicated relay/pub-sub channel.

### Chat

Payload bounds, sanitization, scope separation, duplicate/spam protection,
persistent mute state, persistent channel slow mode, account-level administrator
authorization, in-game moderation commands, millisecond UTC expiry and moderation
audit storage exist. Chat-ban and reports are intentionally out of scope. A future
admin application still needs query UI. Database polling is acceptable for beta
but not high-volume world chat.

### Craft, Cooking, Fishing And Hatchery

Outcomes are server/API authoritative and inventory mutations are transactional.
Craft/Cooking share the recipe activity engine. Fishing uses server-generated
session IDs, validates bite/catch timing, rejects stale sessions and derives a
stable reward operation ID from the session. Hatchery start/claim operations use
idempotency keys and explicit persisted job states. Never move result rolls to
the Client.

### Party

Reward sharing, canonical party versioning, persistent invite expiry, cross-worker
presence, offline membership removal and handoff preservation are implemented.
Remote-worker members remain represented in the HUD without an `OFFLINE` label.
Worker-crash cleanup now marks stale heartbeat presence and applies a short grace
period before membership removal. Dungeon handoff uses a versioned party roster
reservation before transfer. Multi-worker behavior still requires manual PBE
validation whenever handoff or presence code changes.

### Dungeons On Distinct Workers

Signed directed handoff, atomic lease replacement, fencing and acknowledgement are
the correct foundation. Party handoff reserves the versioned complete roster
before moving the first member and logs prepare, validation, cancellation,
rollback and acknowledgement phases. An explicit shared transfer state type and
dedicated relay remain future structural improvements.

### Client

Prediction/reconciliation is correctly presentation-side, but `server.gd`,
`movement_controller.gd`, `worldmap.gd` and the global autoload count are large.
Split network session, lobby, handoff and gameplay receivers; replace broad global
state with domain stores/signals where practical.

### MySQL API

Transactions and domain routes are strong. Several handler files exceed 600-1400
lines and should be split by aggregate/use case. Add a generated route inventory,
repository interfaces, service-scoped auth telemetry and manual query-plan/load
checks for chat, guild and inventory hot paths.

## Validation Policy

Automated test files were removed by project decision on 2026-07-23. Functional
validation is performed in the real PBE flow with structured logs. CI and deploy
retain only Godot import, source formatting, static analysis, syntax checks and
build verification. Manual scenarios live in the canonical Operations runbook.

## Rules For Reduction

1. Reduce duplicated decisions, not merely formatting or line breaks.
2. No cross-domain generic abstraction without at least two stable consumers.
3. Every extraction preserves RPC/API contracts and records a complete manual log trace.
4. Large gameplay changes are separate commits from mechanical moves.
5. Measure frame time, packet size, DB writes and API latency before/after.

## Cross-Repository Cleanup Checklist

### Agent

- [x] Keep gameplay priorities in `FIRST_BETA_ROADMAP.md` and v0.04 acceptance
  in `roadmap_v0.04.md`; thematic documents define contracts only.
- [x] Replace the old pixel-tolerance combat note with deterministic tick replay.
- [ ] Repair the historical mojibake in `ai/CODE_RULES.md` without changing its
  meaning.
- [ ] Review old audit snapshots when the beta ships and archive only documents
  that no longer provide decision history.

### Auth

- [x] Godot headless loads scripts without parse errors.
- [x] No runtime `.env` or secret file is tracked.
- [ ] Separate the HTTP/database adapter from the authentication coordinator if
  either grows beyond its current small responsibility.
- [x] No application-owned `Thread` exists in Auth; the headless editor shutdown
  warning observed locally comes from the restricted Godot editor environment.

### Gateway

- [x] No runtime `.env` or secret file is tracked.
- [ ] Re-run isolated headless shutdown validation in CI; the combined local
  audit was terminated after the restricted editor environment stalled.
- [ ] Keep Gateway limited to handshake, routing and connection lifecycle; do
  not move gameplay reconciliation into it.

### Client

- [x] RPC surface is byte-identical to the Server mirror.
- [x] All tracked JSON files parse and all tracked paths exist.
- [x] Controlled movement uses sequenced input, authoritative ACK and replay
  based on `action_start_input_tick`.
- [x] Remote entities remain presentation/interpolation driven.
- [ ] Split `movement_controller.gd` after live validation into input history,
  deterministic simulation and visual correction components.
- [ ] Split `server.gd` receivers into session, lobby, handoff and gameplay
  adapters while preserving the mirrored RPC surface.
- [ ] Split `worldmap.gd` scene streaming from entity presentation.
- [ ] Remove `ChatPayloads.TYPE_LEGACY` only after confirming every local and
  network message is wrapped by `build_chat` or `build_system`.
- [ ] Inventory and UI scripts disabled for v0.04 remain future content and must
  not be deleted merely because they do not spawn in the beta.

### Server

- [x] RPC surface is byte-identical to the Client mirror.
- [x] All tracked JSON files parse and all tracked paths exist.
- [x] Combat movement phases use the same deterministic helper as the Client.
- [x] Locked combat phases process zero-distance commands instead of creating
  gaps in the input sequence.
- [x] Rename functional `ASpeedTimer` nodes to `ActionTimer`; attack speed is an
  interval and no longer an animation-duration concept.
- [ ] Extract dungeon instance lifecycle and transfer orchestration from
  `portal_manager.gd`.
- [ ] Split inventory use, rewards and equipment operations from `inventory.gd`.
- [ ] Split enemy AI, combat and replication responsibilities in
  `datamoon_enemy.gd`.
- [ ] Measure worldstate packet size and tick cost before changing snapshot
  frequency or compression.

### MySQL API

- [x] No runtime `.env` or secret file is tracked.
- [ ] Run `go vet ./...` and `go build ./...` in CI/VM; Go is not installed in
  the current local execution environment.
- [ ] Split `game_write_handlers.go`, `guild_handlers.go` and
  `inventory_handlers.go` by aggregate/use case.
- [ ] Remove permissive legacy inventory-ID behavior only in the clean beta
  database release that retires migrations 031/032 compatibility.
- [ ] Generate and diff a route inventory so unused endpoints can be removed
  without breaking Server callers.

### Web

- [x] `src/app.js` passes Node syntax validation.
- [x] No runtime `.env` or secret file is tracked.
- [ ] Split the 500+ line application into configuration, routes and page
  rendering when another account flow is added.
- [ ] Add a non-installing `check` script; there is currently no build script
  and invoking package-manager build attempts an unnecessary install.

### Sprites

- [x] Repository intentionally contains source art rather than runtime code.
- [ ] Create a manifest mapping source sprite IDs to Client runtime assets
  before deleting apparently unreferenced art.
- [ ] Detect duplicate binary hashes and obsolete exports only after the
  manifest distinguishes source files from generated variants.

### Release Gates

- [ ] Validate Player movement while commanding companion attacks.
- [ ] Validate Datamoon START/IMPACT/RECOVERY at normal latency and under
  simulated latency/loss.
- [ ] Confirm reconciliation errors converge instead of growing across actions.
- [ ] Run Client, Server, Auth and Gateway headless checks in a writable CI
  profile.
- [ ] Run API vet/build and Web syntax check.
- [ ] Perform the clean database reset before removing historical ID migrations
  or permissive legacy-row handling.
