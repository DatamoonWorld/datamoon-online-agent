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

`crafting.gd` and `cooking.gd` duplicate catalog normalization, ingredient/result
decoration, result construction and API error mapping. Introduce one reusable
recipe activity service parameterized by activity kind, route, source and status
mapping. Keep thin Craft/Cooking facades for RPC/UI semantics. Expected reduction:
roughly 150-220 lines across Client/Server without changing recipes.

### Social Runtime

Party and Guild duplicate online-character lookup, client resolution, invite
delivery, feedback, relay scopes and snapshot fan-out. Extract a social directory
and relay adapter. Do not merge Party/Guild domain rules: leadership, persistence,
reward sharing and dungeon binding remain separate. Expected reduction: 200-350
lines plus lower risk of cross-worker behavior drifting.

### Inventory And Rewards

Server `inventory.gd` mixes inventory access, mutation orchestration, usable-item
reward rolls, rollback, logging and operation-token formatting. Split into
inventory repository facade, item-use/reward service and operation-context helper.
Preserve API transactions as the actual atomic boundary. This is primarily a
readability/testability refactor, not a gameplay rewrite.

### Dungeon And Portals

`portal_manager.gd` combines static portals, local instances, remote handoff,
completion, rewards, timeout/ejection and content parsing. Split configuration,
instance lifecycle and transfer orchestration. Keep one public facade so RPC
handlers do not depend on worker topology.

## Domain Findings

### Combat

Damage authority, target/space validation, action acknowledgements and projectile
de-duplication are cohesive. Improve by moving formulas into immutable typed
combat inputs/results, adding deterministic seeded simulations, and separating
action lifecycle from damage math. Add tests for defense curves, level gaps,
systems, buffs, AoE cadence and simultaneous death. Avoid adding more logic to
`combat.gd` before this split.

### Guild

Persistent membership and role operations belong in the API and snapshots are
server-distributed, which is correct. Add permission matrices in one function,
idempotent moderation operations, offline invite expiry and audit/admin tooling.
Cross-worker chat works through persistence polling but should eventually use a
dedicated relay/pub-sub channel.

### Chat

Payload bounds, sanitization, scope separation and retention exist. Missing
production controls include account-level mute/ban, slow mode, duplicate/spam
fingerprints, report workflow and moderator audit. Database polling is acceptable
for beta but not for high-volume world chat.

### Craft, Cooking, Fishing And Hatchery

Outcomes are server/API authoritative and inventory mutations are transactional.
Craft/Cooking should share an engine; Fishing needs deterministic session IDs and
stronger timing/replay tests; Hatchery should expose explicit job state transitions
and claim idempotency metrics. Never move result rolls to the Client.

### Party

Reward sharing, presence, invites and cross-worker relay are implemented, but the
single file owns too many caches and transport details. Introduce a canonical
party state/version from the API, explicit invite expiry and a reconnect grace
state. Dungeon entry should freeze a versioned party roster for the run.

### Dungeons On Distinct Workers

Signed directed handoff, atomic lease replacement, fencing and acknowledgement are
the correct foundation. Improve with an explicit transfer state machine shared by
source/client/target, retry-safe acknowledgements, target readiness reservation,
source rollback timeout, and integration tests that kill each component at every
transition. Party handoff should reserve all members before moving the first one.

### Client

Prediction/reconciliation is correctly presentation-side, but `server.gd`,
`movement_controller.gd`, `worldmap.gd` and the global autoload count are large.
Split network session, lobby, handoff and gameplay receivers; replace broad global
state with domain stores/signals where practical.

### MySQL API

Transactions and domain routes are strong. Several handler files exceed 600-1400
lines and should be split by aggregate/use case. Add generated route contract
tests, repository interfaces for unit tests, service-scoped auth coverage and
query-plan/load checks for chat, guild and inventory hot paths.

## Rules For Reduction

1. Reduce duplicated decisions, not merely formatting or line breaks.
2. No cross-domain generic abstraction without at least two stable consumers.
3. Every extraction keeps behavior tests and contract goldens green.
4. Large gameplay changes are separate commits from mechanical moves.
5. Measure frame time, packet size, DB writes and API latency before/after.
