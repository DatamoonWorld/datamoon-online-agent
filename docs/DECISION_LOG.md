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
- Evidence and release gates live in `docs/TECHNICAL_AUDIT_2026-07-23.md`.

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
