# Datamoons Online Canonical Agent Instructions

This file is the canonical project-wide base for agent behavior, technical decisions, and creative consistency across the Datamoons Online workspace.

## Source Of Truth

When deeper project context is needed, consult these files first:

1. `ai/AGENT.md`
2. `ai/CODE_RULES.md`
3. `ai/DATAMOON_CREATION_RULES.md`
4. `docs/DATAMOON_BIBLE.md`
5. `docs/WORLD_BIBLE.md`
6. `docs/LINK_SYSTEM.md`
7. `docs/SPECIES_DESIGN_GUIDE.md`

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
- Assume ENet multiplayer until the project formally changes that choice.

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
