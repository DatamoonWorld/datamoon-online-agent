# Datamoons Online - Network Rules

## Purpose

This document defines network rules for agents working across the Datamoons Online repositories.

Networking decisions must optimize for:

- server authority;
- MMO scalability;
- predictable synchronization;
- clean responsibility boundaries;
- resistance to abuse.

---

## Core Networking Model

Assume the current project model unless a newer implementation clearly replaces it:

- ENet-based multiplayer;
- gameplay services in Godot;
- server-authoritative gameplay;
- chunk-based world visibility;
- explicit RPC surfaces between peers;
- mysqlapi used for persistence, not real-time state authority.

---

## Authority Rules

The client is not the authority for critical state.

The gameplay server must own or validate:

- combat results;
- movement relevance;
- spawn and despawn;
- dungeon state;
- quest state transitions;
- reward outcomes;
- inventory-affecting results;
- session-sensitive gameplay actions.

The client may own:

- input collection;
- local rendering;
- interpolation;
- cosmetic feedback;
- short-lived prediction where safe.

---

## RPC Surface Rules

The mirrored `rpc_surface.gd` is a contract, not a casual utility file.

Current rule:

- `datamoon-online-server` and `datamoon-online-client` must keep mirrored RPC surface definitions in sync.

Therefore:

- do not change ordering casually;
- do not update one side without the other;
- do not add ad hoc RPCs only in one repo;
- treat checksum compatibility as a release risk.

If a networked feature needs a new RPC, update both sides together.

---

## Message Design Rules

Network messages should be:

- small;
- explicit;
- validated;
- responsibility-specific;
- stable enough to version safely.

Avoid:

- giant catch-all payloads;
- loosely typed "do anything" RPCs;
- client-generated reward or authority data;
- broadcasting full state when a delta or snapshot is enough.

---

## Reliability Rules

Use reliable delivery for data that cannot be dropped safely, such as:

- authentication flow;
- quest actions;
- inventory-affecting actions;
- dungeon timer snapshots;
- party and guild state updates.

If an action is frequent and recoverable, consider whether a lighter pattern is safer, but do not invent it unless the project actually needs it.

---

## Version And Handshake Rules

Network compatibility is a first-class concern.

Always consider:

- client version checks;
- runtime parity across local and VM environments;
- token verification flow;
- handshake order;
- what happens when a client is newer or older than the server.

When a change can break compatibility, document it and deploy carefully.

---

## Chunk And Interest Rules

The world is chunk-based and server-driven.

Networking should respect that by favoring:

- interest-managed entity updates;
- scoped broadcasts;
- safe spawn and despawn flow;
- joining snapshots for newly relevant areas;
- minimal data for distant or irrelevant entities.

Do not design systems that assume all players always receive all world state.

---

## Service Boundary Rules

Keep network responsibilities separate:

- `auth` handles credentials, token flow, and session validation concerns;
- `gateway` handles connection flow and should not silently absorb gameplay authority;
- `server` owns world and gameplay state;
- `mysqlapi` exposes controlled HTTP persistence endpoints;
- `client` consumes snapshots, feedback, and gameplay events.

If a feature seems easier by collapsing those roles, pause and re-evaluate.

---

## Abuse And Safety Rules

Assume hostile or malformed input is possible.

Validate:

- ids;
- ownership;
- range and proximity;
- action frequency;
- state preconditions;
- quest and dungeon eligibility;
- inventory capacity and item identity.

Every client request should be considered potentially forged or replayed.

---

## Checklist

Before adding a networked feature, answer:

1. Which repo owns the authority?
2. Does this need a new RPC or HTTP route?
3. Can the payload stay small and explicit?
4. What happens under latency or packet loss?
5. What prevents replay or forged input?
6. Does this respect chunked world visibility?
