# Datamoons Online - Economy

## Purpose

This document defines the economic rules the project should follow.

Economy work must stay aligned with:

- server authority;
- controlled persistence;
- meaningful progression;
- anti-abuse constraints;
- MMO sustainability.

---

## Core Economy Identity

The economy should support the Datamoon journey, not replace it.

Players should earn value mainly through:

- combat;
- quests;
- dungeons;
- gathering;
- fishing;
- crafting;
- cooking;
- future world events.

The economy should reward active play, team preparation, and system mastery.
It should not reward AFK loops, excessive alt abuse, or client-side trust.

---

## Primary Value Layers

### Bits

`BIT` is the primary soft currency currently visible in live gameplay data.

Use Bits for:

- quest rewards;
- combat rewards;
- dungeon rewards;
- service costs;
- progression sinks;
- convenience sinks that do not become pay-to-win design patterns.

Bits should be easy to understand and widely useful.

### Items

Items are the second major economic layer.

They include:

- crafting materials;
- cooking ingredients;
- hatchery inputs;
- equipment;
- quest items;
- reward boxes;
- future event items.

Items should create market-like decision pressure even before a formal player trade economy exists.

### Progression Resources

Some rewards are not currency, but still affect the economy because they change account power.

Examples:

- Datamoon XP;
- Link EXP;
- cooking EXP;
- fishing EXP;
- hatch progression materials;
- type-aligned essences such as `datacore_essence`, `patch_essence`, and `glitch_essence`.

These must be balanced alongside Bits and items, not treated separately.

---

## Economy Authority Rules

Economy outcomes are server-authoritative.

The server or mysqlapi must own or validate:

- reward rolls;
- Bit grants;
- item grants and removals;
- quest turn-in rewards;
- dungeon completion rewards;
- crafting and cooking results;
- hatch consumption and results;
- inventory slot legality;
- repeat protection and audit context.

The client may show:

- previews;
- tooltip value hints;
- reward summaries;
- inventory visuals;
- optimistic UI where safe.

The client must not be the source of truth for owned value.

---

## Current Economy Baseline

Based on the active repositories, the economy already includes:

- Bits on quests and combat rewards;
- enemy drop tables;
- dungeon completion rewards;
- itemized drops with chance tables;
- crafting and cooking operations;
- inventory capacity limits;
- quest reward bundles;
- hatchery-related item flows.

Design and implementation should extend these patterns instead of bypassing them.

---

## Faucets

Common value faucets should include:

- enemy defeat rewards;
- quest completion rewards;
- dungeon completion rewards;
- gathering and fishing rewards;
- event participation rewards;
- first-clear or first-time milestone rewards;
- controlled seasonal or beta compensation grants.

Faucets should be explicit and measurable.
Avoid hidden passive faucets that are hard to audit.

---

## Sinks

A healthy economy needs real sinks.

Recommended sink categories:

- crafting costs;
- cooking costs;
- hatchery incubation costs;
- equipment upgrading or repair-like systems if added later;
- travel, convenience, or reset costs when appropriate;
- event entry costs only if they do not block basic progression.

Good sinks remove surplus value while creating interesting choices.
Bad sinks feel like taxes with no strategic value.

---

## Reward Design Rules

### 1. Reward the intended behavior

If the goal is exploration, reward exploration.
If the goal is mastery, reward mastery.
If the goal is party play, part of the reward structure should care about party participation.

### 2. Avoid inflation through stacking systems

When combat, quests, dungeons, and events all reward the same currency, total output rises quickly.

Before adding a new faucet, check:

- how often it can be repeated;
- whether it stacks with existing loops;
- whether it is soloable, multiboxable, or party-amplified;
- whether it produces Bits, progression, items, or all three.

### 3. Preserve item identity

Rare items should not become common filler rewards.

Essences, reward boxes, hatch materials, and dungeon drops should each have a clear acquisition identity.

### 4. Respect inventory friction

Inventory limits are part of the economy.
Do not create reward flows that constantly overflow inventory without deliberate UX support.

---

## Anti-Abuse Rules

Economy systems must assume abuse attempts.

Always consider:

- duplicate requests;
- reconnect abuse;
- reward replays;
- repeated turn-in attempts;
- party reward leeching;
- scripted farming loops;
- alt-account farming;
- client-forged reward payloads.

Prefer:

- operation ids;
- request hashing where already used;
- audit trails;
- ownership validation;
- rate limits;
- proximity checks;
- server-generated reward rolls.

---

## Persistence Rules

Persist only meaningful outcomes.

Good persistence events:

- quest acceptance and completion;
- item creation, removal, and movement;
- Bit changes;
- hatch job creation and claim;
- archive operations;
- cooking and crafting results.

Bad persistence patterns:

- per-frame saves;
- combat tick writes;
- storing temporary combat authority in MySQL;
- writing every preview or UI-only state.

---

## Economy Design Checklist

Before adding a new economy feature, answer:

1. What is the faucet?
2. What is the sink?
3. What prevents abuse?
4. Is the reward solo, party, or account scoped?
5. Does it consume inventory space?
6. Does it require idempotency or auditing?
7. Does it fit the Datamoon progression fantasy?

---

## Implementation Guidance

When implementing economy features:

- prefer mysqlapi endpoints over direct database access from gameplay services;
- keep mutation logic explicit and domain-specific;
- use audit-friendly request context for risky inventory operations;
- keep reward payloads small, validated, and reproducible;
- document major value changes in `docs/DECISION_LOG.md` when they affect multiple systems.
