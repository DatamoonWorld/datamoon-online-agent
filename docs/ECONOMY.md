# Datamoons Online - Economy

> This document defines economy and equipment contracts. Current implementation
> status, priorities and pending work live only in `FIRST_BETA_ROADMAP.md`.

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

## Equipment Progression

This specification is implemented in the PBE codebase. Generated equipment,
upgrade and alternate mutations are authoritative, transactional, idempotent,
and inventory-audited. Equipment is character-owned, but
its combat bonuses apply to whichever Datamoon is currently active. Switching
the active Datamoon must remove the bonuses from the previous active Datamoon
and apply them to the new one immediately.

### Equipment roles and stat pools

Every generated equipment item has exactly three stat entries. Repeated stats
are allowed only up to the cap declared by that equipment's pool. For example,
a Bracelet may roll `ATK` twice but never three times.

| Equipment | Role | Allowed stat entries |
| --- | --- | --- |
| Bracelet | Primary battle equipment; the active Datamoon cannot attack without one | `ATK x2`, `CRIT x1`, `SKILL_DAMAGE x1`, `HP x2`, `MP x2` |
| Hood | Offensive equipment | `ATK x2`, `CRIT x1`, `SKILL_DAMAGE x1`, `HP x1` |
| Shoes | Defensive equipment | `DEF x2`, `HP x2`, `MP x1` |

Generation uses weighted random selection without exceeding the per-stat cap.
`ATK`, `DEF`, `HP`, and `MP` use the common/high-weight category. `CRIT` and
`SKILL_DAMAGE` use the rare/low-weight category. Concrete numeric weights remain
data-driven balance values and must not be hard-coded in gameplay handlers.
Stat curves and target-level upgrade chances also belong to the equipment item
catalog. Client and Server must read those values from item data rather than
maintaining mirrored constants in scripts.

There is no equipment rarity or quality system. Critical Damage and Attack Speed
are not valid equipment stats in this version and are reserved for a future pass.

Equipment changes are blocked while the character is in combat. Outside combat,
equipping, unequipping, or switching an item recalculates the active Datamoon's
effective stats immediately.

Activating a Datamoon through the Archive restores its current HP to the
equipment-adjusted effective maximum and persists that value before confirming
the swap. If persistence fails, the active selection and runtime Datamoon are
rolled back. Archive, NPC, and portal interactions are blocked during combat so
this safe interaction cannot be used as combat healing.

### Main item upgrades

Upgradeable equipment stops at `+10`. An `Upgrade
Chip` is the dungeon material used for an upgrade attempt. Every attempt consumes
one chip. Failure leaves the equipment at its current level and never destroys or
downgrades it.

Upgrade success is rolled by the authoritative backend using the target level:

| Target level | Success chance |
| --- | ---: |
| `+1` | 100% |
| `+2` | 90% |
| `+3` | 80% |
| `+4` | 70% |
| `+5` | 60% |
| `+6` | 45% |
| `+7` | 35% |
| `+8` | 20% |
| `+9` | 5% |
| `+10` | 1% |

The planned stat values by upgrade level are:

| Stat | +0 | +1 | +2 | +3 | +4 | +5 | +6 | +7 | +8 | +9 | +10 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Attack | 30 | 40 | 52 | 66 | 82 | 100 | 124 | 154 | 190 | 232 | 280 |
| Defense | 10 | 14 | 19 | 25 | 32 | 40 | 50 | 62 | 76 | 92 | 110 |
| Critical chance | 0.01 | 0.02 | 0.03 | 0.04 | 0.05 | 0.06 | 0.08 | 0.09 | 0.11 | 0.12 | 0.14 |
| Skill damage | 0.02 | 0.04 | 0.06 | 0.08 | 0.10 | 0.12 | 0.16 | 0.20 | 0.24 | 0.28 | 0.32 |
| HP | 200 | 240 | 285 | 335 | 390 | 450 | 530 | 630 | 750 | 890 | 1050 |
| MP | 60 | 80 | 103 | 129 | 158 | 190 | 230 | 278 | 334 | 398 | 470 |

The table represents cumulative values. Every stat entry uses the full value
for the item's current upgrade level, and one successful upgrade advances all
three entries together. Therefore, two `ATK` entries at `+2` grant
`52 + 52 = 104 ATK`.

### Unscan equipment boxes

Equipment enters the economy as a box item with the same display name and sprite
as the resulting equipment, prefixed with `[UNSCAN]`. Using the box consumes it
and creates the corresponding equipment with three server-generated stat entries.

Unscan boxes use the normal container contract. Their `guaranteed_rewards`
contains one item reward with `metadata_generator: equipment_stats`; do not add
a parallel `unscan_result` field. The metadata generator is an authoritative API
registry key, while target item, amount, stat pool, curves and chances remain
catalog data.

Generation happens once on the authoritative backend. The result, stat order,
upgrade level, and unique item identity are persisted as instance metadata. The
operation must be transactional, idempotent, and auditable so retrying a request
cannot duplicate either the box or the generated equipment.

Every `description.text` in item JSON is a Client language key. Raw player-facing
sentences do not belong in Server or API catalogs.

### Alternate Chip

The `Alternate Chip` is the consumable reroll material used by the equipment
terminal.

Using it should:

- let the player select one existing stat entry on the target item;
- remove that entry from the cap calculation before rolling its replacement;
- replace it with a random eligible stat from the item's weighted pool without
  exceeding any per-stat cap;
- consume the chip only in the same successful transaction as the reroll;
- preserve upgrade level and all stats not selected for replacement;
- persist an auditable, idempotent inventory operation.

The server/mysqlapi must perform the roll. The client may select the target item
and display the result, but it must not choose or submit the resulting stat.

### Equipment NPC

The equipment NPC opens a dedicated window with two tabs:

- `Upgrade`: accepts equipment plus the configured upgrade materials and submits
  a server-authoritative attempt using the target-level chance table;
- `Alternate`: accepts equipment plus an `Alternate Chip`, lets the player select
  the stat entry to replace, and displays the server-generated result.

The client may preview cost, chance, current stats, and possible pool entries.
It must never decide success, consume materials locally, or generate a stat.

Both tabs show one equipment slot and one material slot. Left-clicking a
compatible inventory item stores only its `inventory_item_id` and renders a
local visual reference; it does not move, reserve, or remove the item. Selecting
another item for the same role replaces that reference, and closing the window
clears every reference. Left-clicking a populated terminal slot clears that
reference without touching the inventory item. This keeps disconnects and
abandoned interactions lossless.

Upgrade and Alternate requests include the selected equipment and material
inventory row IDs. The backend locks both rows transactionally, verifies their
character ownership and catalog IDs, consumes exactly the selected material
stack, and returns a refreshed inventory snapshot. The target equipment must be
unequipped; the Client filters it and the MySQL API independently rejects an
equipped row. Alternate presents the three generated stat entries as mutually
exclusive checkboxes and submits only the selected index. The backend remains
the sole authority for the replacement result.

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
