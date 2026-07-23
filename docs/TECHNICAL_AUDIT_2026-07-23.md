# Full Technical Audit - 2026-07-23

## Scope And Method

Auth, Gateway, Server, Client and MySQL API were reviewed after fetch/prune on
2026-07-23. The audit followed login/connection first, then gameplay authority,
persistence, handoff, performance, dead code, configuration and tests.

Static review covered entry points, ENet RPCs, internal HTTP routes, tickets,
sessions, movement/combat, worldstate, migrations and deployment configuration.

## Executive Summary

The gameplay architecture is strong for an early beta: authority is server-side,
persistence is isolated behind domain APIs, tickets are short-lived/single-use,
sensitive writes are transactional/idempotent, and replication uses chunk
interest, deltas and byte budgets.

The largest remaining risk is transport security. Login credentials cross the
public Client -> Gateway ENet connection without encryption. Production-like
secrets also exist in MySQL API Git history. These require deployment and secret
rotation work and cannot be completed safely with a source-only patch.

## Findings

### Critical

#### SEC-01 - Public credentials travel over raw ENet

- Reproduction: capture client/gateway traffic during login or registration.
- Cause: no TLS/DTLS or reviewed encrypted application envelope.
- Impact: an on-path attacker can read credentials or modify requests.
- Fix: no unilateral patch; it would break the live protocol.
- Recommendation: version and deploy an encrypted public transport with validated
  server identity. Do not invent custom cryptography.

#### SEC-02 - Secrets committed in `.env`

- Reproduction: inspect tracked file/history in `datamoon-online-mysqlapi`.
- Cause: `.env` entered commits before ignore protection.
- Impact: historical repository readers may retain DB/API access until rotation.
- Fix: `.env` removed from the index but retained locally/ignored; `.env.example`
  now records non-secret requirements.
- Recommendation: rotate `INTERNAL_API_TOKEN` and `MYSQL_PASSWORD`, audit use and
  purge Git history if policy permits. Untracking does not revoke old values.

#### FLOW-01 - Required client versions disagreed

- Reproduction: default client `0.03` connects to default gateway `0.02`.
- Cause: gateway settings lagged client/server beta version.
- Impact: compatible current clients could be rejected before login.
- Fix: gateway config/project defaults aligned to `0.03`.

### High

#### SEC-03 - Auth listener has no gateway identity

- Reproduction: reach Auth port 5200 and submit its expected RPC directly.
- Cause: network placement/firewall is the only caller-authentication layer.
- Impact: an exposed listener bypasses gateway version/address controls.
- Fix: startup now fails closed and obsolete port 5300 listener was removed.
- Recommendation: bind privately, firewall the port, then add a mutually
  authenticated channel or signed gateway request envelope.

#### SEC-04 - Shared API token has broad authority

- Cause: all internal callers use one API-wide bearer token.
- Impact: compromise of one runtime exposes unrelated persistence operations.
- Recommendation: per-service credentials, route scopes, rotation overlap and
  attributable audit records.

#### FLOW-02 - No ordinary game-session resume

- Reproduction: interrupt the game-server connection outside planned handoff.
- Cause: tickets are correctly one-time and no separate resume grant exists.
- Impact: transient failures return users to login.
- Recommendation: a short-lived resume capability bound to worker, character,
  session epoch and strict expiry; never reuse the original ticket.

### Medium

#### PERF-01 - Enemy perception performs global scans

- Reproduction: increase hostile enemies/player Datamoons and profile
  `_scan_for_target()` every 250 ms.
- Cause: every hostile iterates `datamoon_map.get_children()`.
- Impact: O(enemies x player Datamoons) CPU growth.
- Recommendation: query the existing spatial/chunk index, cap candidates and add
  scan duration/candidate metrics.

#### SEC-05 - Login limiter was reconnect-sensitive

- Cause: only per-peer state existed and vanished on disconnect.
- Impact: reconnects bypassed the intended throttle.
- Fix: rolling 60-second per-address bucket (30 attempts), stale pruning and the
  existing two-second per-peer cooldown.
- Residual: state is in-memory/per-instance; durable edge protection remains due.

#### API-01 - Internal HTTP accepted ambiguous input

- Cause: raw token without `Bearer`, normal equality and trailing JSON accepted.
- Impact: weaker protocol strictness and parser ambiguity.
- Fix: exact scheme, constant-time compare, trailing-document rejection,
  authenticated `no-store`, and generic readiness errors.

#### PERF-02 - Scene-tree scans in social/runtime lookups

- Cause: helpers iterate player/entity children rather than stable indexes.
- Impact: avoidable linear work as concurrency grows.
- Recommendation: profile, then maintain lifecycle-safe entity indexes.

### Low

#### DEAD-01 - Obsolete Auth listener

- Cause: unused autoload still opened port 5300.
- Impact: attack surface and operational confusion.
- Fix: autoload, settings and script removed.

#### OPS-01 - Non-portable quality gate

- Cause: fixed `C:\Godot\Godot.exe` and omitted P2 combat coverage.
- Impact: false local failures and incomplete regression run.
- Fix: resolve `GODOT_BIN`, PATH, console/GUI fallbacks and include P2.

#### GAME-01 - Fractional skill damage was truncated

- Reproduction: set `skill_damage` to `1.5`; final damage used an integer value.
- Cause: generic stat finalization converted the decimal stat to `int`.
- Impact: fractional bonuses produced lower damage than the combat contract.
- Fix: preserve `SKILL_DAMAGE` as a non-negative float; P2 test now passes.

#### TEST-01 - RPC goldens lagged the mirrored contract

- Cause: targeted unequip changed identical Client/Server RPC surfaces without
  updating either SHA-256 fixture.
- Impact: contract test failed even though both runtime surfaces matched.
- Fix: coordinated both golden hashes after byte-for-byte comparison.

#### TEST-02 - Client preload raced test shutdown

- Cause: the content preloader queued all resources for short test scenes.
- Impact: random parse/load noise appeared after the test reported success.
- Fix: skip automatic bulk preload only when the initial scene is under `tests/`.

## Boundary Assessment

- Client: treated as untrusted for outcomes. Public credential transport remains
  critical.
- Gateway: routing-only with stronger throttling; should become the encrypted
  public boundary and must never log credentials.
- Auth: bcrypt/generic failure behavior is sound; listener needs private binding
  and explicit service identity.
- Server: admission, payload limits, token buckets, authority, fencing and ticket
  consumption are strong.
- MySQL API: transactions, ownership/idempotency and domain routes are strong;
  shared-token blast radius and historical secrets remain material.

## Gameplay And Consistency

- Movement uses client intent, server validation and reconciliation.
- Damage, cooldowns, hits, projectiles and rewards resolve server-side.
- Inventory/economy writes are transactional API operations.
- Baseline/delta snapshots are space/chunk scoped, budgeted and observed.
- Handoff is signed, one-time and protected by worker leases.
- Known residual defects: dungeon transition pull-back and skill animation snap.

## Changes Applied

- Gateway: version alignment, reconnect-resistant throttling, startup failure.
- Auth: removed dead port 5300 listener/config, startup failure handling.
- MySQL API: strict bearer auth/JSON, safe readiness, no-store, tests, expanded
  example config, and `.env` removed from tracking.
- Server: portable quality gate and P2 combat test inclusion.
- Server: preserve fractional skill-damage multipliers and refresh the RPC golden.
- Client: refresh the mirrored RPC golden and avoid bulk preload in test runs.
- Agent: canonical architecture and this audit.

## Validation

- Godot 4.7.1 stable headless parsing passed for Auth, Gateway, Server and Client.
- All 8 Server scenes passed: P0 hardening; P1 snapshot, observability, hotbar,
  inventory replication, activity runtime and contract; P2 combat refactor.
- Client P1 snapshot/contract scene passed without preload race noise.
- Go tests/vet could not run because Go is not installed/on PATH locally. New Go
  tests require CI or a Go-equipped workstation before deployment.
- Server fixtures still print missing `MainMap` node errors, observability socket
  warnings and ObjectDB leak warnings despite successful assertions/exit codes.
  The harness should isolate autoloads and make unexpected engine errors fatal.
- No production packet interception, load test, DB integration test or VM
  firewall/listener verification was performed locally.

## Prioritized Next Steps

| Priority | Work | Effort | Risk | Benefit | Dependency |
|---|---|---:|---:|---:|---|
| P0 | Rotate leaked DB/API secrets and audit use | S | Low | Critical | VM/DB/repo admin |
| P0 | Encrypt Client -> Gateway transport | L | Medium | Critical | protocol/deployment |
| P0 | Restrict Auth/API listener exposure | S | Low | High | firewall/systemd |
| P1 | Per-service API identities/scopes | M | Medium | High | rollout plan |
| P1 | Add safe session resume grants | M | Medium | High | cross-repo contract |
| P1 | Spatial enemy perception | M | Medium | High | profiling/load harness |
| P1 | Go CI tests/vet | S | Low | High | Go toolchain/CI |
| P2 | Replace measured scene-tree hot scans | M | Medium | Medium | profiling evidence |
| P2 | Fix transition pull-back/skill snap | M | Medium | Medium | replay tests |
| P2 | Packet-loss/entity load tests | L | Low | High | test environment |

## Release Gate

Do not promote until Go tests/vet and Godot scene tests pass, secrets are rotated,
listener/firewall exposure is verified, client/gateway compatibility is assured,
and every service has a documented rollback path.
