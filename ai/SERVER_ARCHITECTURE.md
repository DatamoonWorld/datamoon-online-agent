# Datamoons Online - Server Architecture

## Purpose

This document defines the working architecture across the Datamoons Online runtime repositories.

It exists to keep new features aligned with the current service boundaries.

---

## Runtime Overview

The project currently operates as a multi-repo game stack with separate responsibilities:

- `datamoon-online-auth`
- `datamoon-online-gateway`
- `datamoon-online-server`
- `datamoon-online-mysqlapi`
- `datamoon-online-client`
- `datamoon-online-web`

For the active beta stack, the core gameplay services are:

- `datamoon-api`
- `datamoon-auth`
- `datamoon-gateway`
- `datamoon-server`

`datamoon-web` may remain disabled during beta when it is not part of the live gameplay loop.

---

## Responsibility Split

### Auth

`datamoon-online-auth` should own:

- authentication-adjacent runtime behavior;
- token/session-oriented checks;
- connection flow support for gameplay entry.

It should not become the hidden owner of unrelated gameplay systems.

### Gateway

`datamoon-online-gateway` should own:

- initial connection flow;
- handoff-oriented responsibilities;
- network boundary concerns that are not full gameplay authority.

It should not silently become a second game server.

### Server

`datamoon-online-server` is the gameplay authority.

It should own:

- world simulation;
- combat;
- chunks and visibility;
- quests;
- dungeons;
- party and guild gameplay state;
- NPC and portal interaction rules;
- reward distribution;
- player-to-world logic.

### MySQL API

`datamoon-online-mysqlapi` is the persistence boundary.

It should own:

- validated game persistence operations;
- migrations;
- controlled inventory mutations;
- character, Datamoon, guild, quest, and economy persistence;
- internal HTTP contracts for game services.

It should not be used as the real-time combat loop authority.

### Client

`datamoon-online-client` should own:

- input;
- UI;
- camera;
- interpolation;
- VFX and SFX;
- player-facing presentation;
- local usability features.

It should not be trusted as the final authority for persistent or competitive outcomes.

---

## Data Flow

The common pattern should be:

1. Client sends an action request to the gameplay server.
2. Server validates live gameplay conditions.
3. Server resolves the gameplay result.
4. If persistence is needed, server calls mysqlapi.
5. Server sends player feedback and updated snapshots.

This keeps moment-to-moment authority in the gameplay server and long-term state in mysqlapi.

---

## Architectural Defaults

Prefer these defaults unless code clearly establishes a newer pattern:

- Godot gameplay services are headless runtime authorities;
- mysqlapi is the only safe place for database mutations;
- JSON-driven content definitions are preferred for tuneable gameplay data;
- mirrored RPC contracts between client and server must stay synchronized;
- major gameplay state should be reconstructable from server truth and persisted snapshots.

---

## Where New Features Belong

Use this routing rule:

- if it changes live world behavior, it likely belongs in `datamoon-online-server`;
- if it changes persistence semantics, it likely needs mysqlapi work;
- if it changes connection or auth flow, it likely touches `auth` or `gateway`;
- if it only changes presentation, it likely belongs in `client`;
- if it introduces cross-repo assumptions, document them in the agent docs and decision log.

Do not place a feature in a repo just because it is faster there.

---

## Content Architecture

The server already uses data-driven content patterns for systems such as:

- quests;
- dungeons;
- NPC definitions;
- item catalogs;
- reward tables;
- recipes;
- enemy spawn definitions.

Prefer extending those content pipelines before writing hardcoded one-off gameplay branches.

---

## Operational Rules

The current deployment model uses:

- `pbe` for active gameplay services;
- `main` for repos that are not following the beta runtime track in the same way;
- headless Godot runtime for auth, gateway, and server;
- a compiled Go binary for mysqlapi.

When changing runtime-sensitive behavior, always consider:

- local and VM parity;
- Godot version parity;
- import metadata refresh for Godot services;
- systemd restart impact.

---

## Architecture Smells

Pause if a solution does any of the following:

- puts gameplay authority in the client;
- adds direct DB access from Godot services;
- duplicates the same domain logic in multiple repos;
- turns gateway into a gameplay rules engine;
- makes mysqlapi responsible for per-frame live simulation;
- requires whole-world loading on the client.

---

## Checklist

Before implementing a cross-repo feature, answer:

1. Which repo owns live authority?
2. Which repo owns persistence?
3. Which repo owns UI feedback?
4. Does this require mirrored RPC changes?
5. Does this require a new mysqlapi route?
6. Does this preserve the current service boundaries?
