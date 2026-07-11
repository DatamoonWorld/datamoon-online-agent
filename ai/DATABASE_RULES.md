# Datamoons Online - Database Rules

## Purpose

This document defines persistence rules for Datamoons Online.

It is mainly about how gameplay services should use `datamoon-online-mysqlapi` and how agents should think about database-backed systems.

---

## Core Rule

Gameplay services should not mutate MySQL directly.

Use mysqlapi as the controlled persistence boundary for:

- characters;
- Datamoons;
- inventory;
- quests;
- hatchery jobs;
- guild state;
- Bits and progression values;
- audit-sensitive gameplay rewards.

---

## Persistence Responsibilities

MySQL is for durable state.

Good database state includes:

- accounts and users;
- characters;
- Datamoon ownership and progression;
- inventory and equipment;
- quest progress;
- guild membership and roles;
- hatch jobs;
- long-term economy values.

MySQL is not the authority for:

- frame-by-frame movement;
- combat tick resolution;
- transient dungeon combat state;
- temporary visual state;
- client-only UI preferences unless explicitly chosen.

---

## API-First Rule

If a gameplay feature needs persistence, prefer:

1. a specific mysqlapi route;
2. validated request payloads;
3. explicit success and error responses;
4. ownership and state checks in the API layer.

Avoid generic "execute arbitrary mutation" patterns.

Domain-specific routes are safer and easier to audit.

---

## Current Patterns To Preserve

The current mysqlapi already establishes useful patterns such as:

- internal bearer token authentication;
- health and readiness endpoints;
- route-specific handlers;
- transaction-based inventory mutations;
- ownership checks by `user_id` and `character_id`;
- request hashing and operation ids for sensitive flows;
- inventory audit trail support;
- catalog-backed validation;
- automatic or controlled migrations.

New persistence features should extend these patterns.

---

## Transaction Rules

Use transactions when a feature changes multiple related records.

Common examples:

- consuming inputs and granting outputs;
- quest completion with multiple rewards;
- hatch claim flows;
- equipment moves;
- archive swaps;
- guild role mutations;
- reward payout plus inventory insertion.

A partial write on a value-sensitive feature is usually worse than a failed request.

---

## Idempotency Rules

Some operations are replay-prone and should be idempotent or deduplicated.

High-risk examples:

- crafting;
- cooking;
- hatch start or claim;
- reward grants triggered by retries;
- inventory mutations after reconnects.

Use:

- operation ids;
- request hashes;
- cached operation lookup;
- explicit conflict handling.

---

## Validation Rules

Database-backed mutations should validate:

- actor ownership;
- target existence;
- inventory capacity;
- item identity and allowed metadata;
- quest state;
- guild permissions;
- repeatability rules;
- positive or bounded numeric amounts.

Do not trust upstream callers to have already validated everything.

---

## Catalog Rules

When item or Datamoon data is content-driven, the API should rely on catalog-backed validation instead of scattered magic constants.

The current mysqlapi already mirrors catalog data for validation purposes.

Preserve that direction when adding:

- new items;
- recipes;
- hatch outputs;
- progression resources;
- reward box behaviors.

---

## Migration Rules

Schema changes should be explicit and reversible where practical.

When changing persistence shape:

- add or update migrations;
- keep rollout order in mind;
- avoid undocumented manual DB edits as the default path;
- make sure runtime services can survive the migration boundary cleanly.

If a migration changes how multiple repos behave, record it in `docs/DECISION_LOG.md`.

---

## Performance Rules

Persistence work must respect MMO load.

Avoid:

- per-frame writes;
- per-hit DB mutations;
- chatty multi-request loops for one logical action;
- repeated full snapshot rebuilds when a narrow mutation is enough.

Prefer:

- batched writes;
- checkpoint saves;
- event-based persistence;
- concise read and write paths;
- indexed lookups for high-frequency entities.

---

## Failure Handling Rules

Every persistence call should have a failure strategy.

Consider:

- what the player sees;
- whether the operation can be retried safely;
- whether the server should roll back local state;
- whether inventory or reward state can become duplicated;
- whether the error should be logged as operational or suspicious.

---

## Checklist

Before adding a database-backed feature, answer:

1. Why does this need persistence?
2. Which repo should own the mutation?
3. Does it need a transaction?
4. Does it need idempotency?
5. What ownership checks are required?
6. What happens if the API call fails halfway through the gameplay flow?
