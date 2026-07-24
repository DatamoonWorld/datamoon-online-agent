# Code Health And Domain Review

Last full static pass: 2026-07-23. Scope: approximately 45,000 code lines across
Auth, Gateway, Server, Client, MySQL API and Web.

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

### Dungeon And Portals

`portal_manager.gd` combines static portals, local instances, remote handoff,
completion, rewards, timeout/ejection and content parsing. Split configuration,
instance lifecycle and transfer orchestration. Keep one public facade so RPC
handlers do not depend on worker topology.

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
server-distributed, which is correct. Add permission matrices in one function,
idempotent moderation operations, offline invite expiry and audit/admin tooling.
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
Craft/Cooking should share an engine; Fishing needs deterministic session IDs and
stronger timing/replay telemetry; Hatchery should expose explicit job state
transitions and claim idempotency metrics. Never move result rolls to the Client.

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
the correct foundation. Improve with an explicit transfer state machine shared by
source/client/target, retry-safe acknowledgements, target readiness reservation,
source rollback timeout, and explicit logs for manually interrupting each
component at every transition. Party handoff should reserve all members before
moving the first one.

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
