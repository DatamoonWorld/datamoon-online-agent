# Datamoons Online Canonical Agent Instructions

This file is the mandatory canonical entry point for every AI or automation
working anywhere in the Datamoons Online workspace. Read it before inspecting or
changing another repository, then read every thematic document relevant to the
requested domain. Repository-local `AGENTS.md` files may add constraints but may
not replace this index.

## Source Of Truth

When deeper project context is needed, consult these files first:

1. `ai/AGENT.md`
2. `ai/CODE_RULES.md`
3. `ai/NETWORK_RULES.md`
4. `ai/SERVER_ARCHITECTURE.md`
5. `ai/DATABASE_RULES.md`
6. `ai/GODOT_STANDARDS.md`
7. `ai/DATAMOON_CREATION_RULES.md`
8. `docs/DATAMOON_BIBLE.md`
9. `docs/WORLD_BIBLE.md`
10. `docs/LINK_SYSTEM.md`
11. `docs/COMBAT_SYSTEM.md`
12. `docs/ADVANTAGE_SYSTEM.md`
13. `docs/ECONOMY.md`
14. `docs/QUEST_DESIGN.md`
15. `docs/DUNGEON_RULES.md`
16. `docs/WORLD_EVENTS.md`
17. `docs/SPECIES_DESIGN_GUIDE.md`
18. `docs/DECISION_LOG.md`
19. `docs/TECHNICAL_AUDIT_2026-07-23.md`
20. `docs/CODE_HEALTH.md`
21. `docs/OPERATIONS.md`
22. `docs/SERVER_ARCHITECTURE_REVIEW.md`

If this file is ever too brief for a decision, the files above win on detail.

## Scope

These rules apply across:

- `datamoon-online-auth`
- `datamoon-online-client`
- `datamoon-online-gateway`
- `datamoon-online-mysqlapi`
- `datamoon-online-server`
- `datamoon-online-sprites`
- `datamoon-online-web`

## Project Identity

Datamoons Online is a 2D top-down MMORPG focused on monster taming, real-time combat, and direct control of Datamoons.

Core identity:

- Godot 4.7 is the default engine assumption for client and game-side services unless a folder clearly says otherwise.
- Datamoons are not generic monsters. They must preserve the "Data + Moon" identity in gameplay, visuals, lore, and systems.
- The player can directly control the human character and the active Datamoon. This is a central gameplay pillar, not a minor feature.

## Architecture Defaults

Use these defaults unless the code in the target folder clearly establishes a newer pattern:

- Server-authoritative logic for combat, rewards, inventory, progression, capture, evolution, and persistent state.
- Client handles input, UI, camera, animation, prediction, interpolation, and visual feedback.
- Gateway handles initial connection flow and should not silently become game-logic authority.
- Auth handles credentials, session rules, and token validation.
- MySQL API handles controlled persistence and should expose game-specific operations instead of dangerous generic access.
- Use secure WebSocket (`wss://`) for public login/registration and ENet for
  latency-sensitive gameplay unless a documented decision changes either path.

## World And Networking Rules

- The world is chunk-based and server-driven.
- Do not design solutions that require loading the entire world on the client.
- Prefer chunk streaming, interest management, safe spawn/despawn, and controlled preload behavior.
- Network messages should be small, explicit, validated, and separated by responsibility.
- Always consider latency, packet loss, ordering, spam protection, and abuse cases.

## Persistence Rules

- MySQL is for persistent state such as accounts, characters, Datamoons, inventory, progression, quests, guilds, and economy data.
- Do not treat the database as the real-time authority for combat or movement.
- Avoid per-frame or per-attack persistence patterns.
- Prefer cache, batching, checkpoints, event-based saves, and auditable logs for sensitive systems.
- Persist audit records for inventory, currency, rewards and administrative
  mutations, with a 180-day default retention even in PBE. New sensitive
  features must define audit and cleanup behavior before release.
- Keep movement, combat ticks, presence, heartbeat and ordinary chat out of
  database audits. Never record passwords, tokens, tickets or chat content.

## Implementation Checklist

Before proposing or writing code, answer these questions for the target change:

1. Does this run on the client, the server, or both?
2. Who is the authority?
3. Does it require network synchronization?
4. Does it require persistence?
5. Can a player abuse it?
6. Does it scale for MMO load?
7. Does it stay modular and maintainable?

When responding, be direct, point out risks, explain trade-offs, and avoid approving weak solutions for convenience.

## Creative Rules

When creating Datamoons or related lore:

- Keep the creature tied to data, lunar influence, ecosystem role, technology, mystery, evolution, or world impact.
- Use one dominant concept instead of several competing core ideas.
- Respect the defined type logic: `Datacore`, `Patch`, or `Glitch`.
- Design with an evolutionary direction in mind: `Code -> Nex -> Omega`.
- Lore, gameplay, and combat function should reinforce each other.

## Collaboration Rules

- Preserve the existing architecture unless there is a clear reason to change it.
- Separate conceptual guidance from implementation guidance when possible.
- Ask follow-up questions only when the missing information materially changes the safest solution.
- If a fast solution harms architecture, balance, MMO scalability, or project identity, say so and propose a better path.
- Functional validation is manual and log-driven by project decision. Do not add
  automated test files or test-only runtime hooks; keep import, formatting,
  static-analysis and build checks.

## Production Deploy Defaults

When helping with production updates, assume the VM repositories live under:

- `/opt/datamoon/datamoon-online-auth`
- `/opt/datamoon/datamoon-online-gateway`
- `/opt/datamoon/datamoon-online-mysqlapi`
- `/opt/datamoon/datamoon-online-server`
- `/opt/datamoon/datamoon-online-web`

Known systemd units:

- `datamoon-api.service` for `datamoon-online-mysqlapi`
- `datamoon-auth.service` for `datamoon-online-auth`
- `datamoon-gateway.service` for `datamoon-online-gateway`
- `datamoon-server@overworld.service` for the overworld game worker
- `datamoon-server@dungeon-1.service` for the dungeon/instance game worker

Production game workers should run through the templated `datamoon-server@...` units. Keep the non-templated `datamoon-server.service` stopped and disabled unless the user explicitly asks to use it for a local/single-process test.

Default branch for deploy examples is `pbe` unless the user says otherwise.

Use the coordinated deployment documented in `docs/OPERATIONS.md` and
`ops/update_vm.sh`. Do not deploy services independently unless performing a
documented incident rollback.

Treat `docs/OPERATIONS.md` as the only source of deploy commands. Agents must
read this `AGENTS.md` file before changing that runbook or executing a release.

If a database schema shape changed but base migrations were edited instead of adding a new migration, give the user the explicit SQL to run manually on the server. Do not assume the migration runner will apply edits to already-applied migration files.

Before telling the user a deploy is complete, verify:

- `git pull` reached the expected commit.
- The relevant service restarted successfully.
- Recent `journalctl` logs do not show startup errors.
- For Godot server deploys, the headless import completed before service start.
