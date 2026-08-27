# Datamoons Online - Dungeon Rules

> This document defines the dungeon contract. Current implementation status,
> priorities and pending work live only in `FIRST_BETA_ROADMAP.md`.

## Purpose

This document defines the rules for instanced dungeons in Datamoons Online.

Dungeons should provide:

- focused combat challenges;
- party coordination opportunities;
- reward concentration;
- progression milestones;
- reusable endgame structure later.

---

## Dungeon Identity

Dungeons are not just closed combat rooms.
They should feel like high-pressure spaces where:

- combat composition matters;
- type advantage matters;
- player and Datamoon control matter;
- time pressure matters;
- rewards justify the commitment.

---

## Instance Model

Dungeons are instanced and server-driven.

The server should own:

- instance creation;
- instance membership;
- enemy spawns;
- timers;
- completion state;
- reward distribution;
- exit or failure handling.

The client may display:

- timer HUD;
- portal interaction prompts;
- reward summaries;
- state feedback.

The client must not own dungeon truth.

Each dungeon template belongs to a Node through its `node_id` and uses a
cataloged static scene on the instance worker. The active runtime space is not
the template ID: it is `dungeon:<template_id>:<serial>`. The template defines
content and rules; the serial identifies the isolated live instance.

---

## Entry Rules

Dungeon templates do not own physical overworld entry portals. A world portal
with kind `dungeon_selector` lists its configured `template_ids`; an empty list
means every enabled dungeon template. The Server creates that portal from the
shared portal scene plus world JSON. The Client selector shell is an authored
`.tscn` scene and creates only the variable option rows at runtime.

Selecting an option stores the safe `return_position` configured by the
overworld portal before handoff. It must be adjacent to, not on top of, the
portal trigger. Do not add `entry_portal` to a dungeon template or duplicate one
overworld portal per dungeon merely to enter it.

Dungeon entry should validate:

- portal existence;
- interact range;
- template validity;
- party compatibility where relevant;
- current instance reuse rules;
- return point storage.

If a party is already bound to an active instance for the same template, members should rejoin that instance instead of creating duplicates.

---

## Membership Rules

Membership matters for both logic and fairness.

Recommended rules:

- a player inside the dungeon should belong to that instance explicitly;
- removing a player from the party may eject them from party-bound dungeons;
- disbanding the party may eject remaining members if the design requires group ownership;
- disconnect cleanup must not leave broken instance membership behind.

The current project already follows this direction.

---

## Timer Rules

Dungeons should have explicit timer windows.

Current template data supports:

- `timeout_seconds_min`
- `timeout_seconds_max`

Timer rules should be:

- visible to the player;
- authoritative on the server;
- able to eject players cleanly when expired;
- consistent for all members of the same instance.

---

## Encounter Rules

Dungeon encounters should be authored with clear intention.

Enemy definitions may include:

- type;
- position;
- level bounds;
- aggro range;
- move speed;
- reset distance;
- reward bundles.

Bosses should feel structurally different from regular enemies through:

- stronger pressure;
- clearer telegraphing;
- reward importance;
- instance completion significance.

Bosses reuse the regular species scene, sprites and animations. Their encounter
definition applies server-authoritative multipliers after normal species/level
stats are resolved. Do not fork a second Datamoon scene only to increase stats.

Boss behavior can be declared as HP-threshold phases in the dungeon template.
The server applies the active phase to skill availability, skill cooldowns and
AI tuning; the Client receives only the resulting boss identity and
authoritative state.
Its centered top HUD is presentation: it appears while the tracked boss is
alive, in the same space and within configured range, and disappears when those
conditions stop being true.

The beta daily reset is midnight in Brasilia (`03:00 UTC`). Dungeon return
handoff must preserve a safe point adjacent to the entry portal so returning
players do not immediately retrigger it.

---

## Completion Rules

Dungeon completion should happen through explicit success conditions.

The current baseline marks completion when the tracked boss dies.

Completion should then trigger:

- instance state update;
- completion reward logic;
- player feedback;
- controlled exit or lingering cleanup behavior.

Avoid ambiguous completion states.

---

## Reward Rules

Dungeon rewards may include:

- Datamoon XP;
- Link EXP;
- Bits;
- guaranteed item drops;
- chance-based item drops;
- future event tokens or progression unlocks.

Dungeon rewards should justify:

- prep time;
- travel time;
- party coordination;
- failure risk.

Do not let dungeon rewards trivialize overworld progression.

### Equipment progression rewards

`moonlight_depths` is the reference configuration for this reward contract.

The current dungeon grants one `Upgrade Chip` on eligible completion and rolls
an independent 5% chance to grant one `Alternate Chip`. These materials are
dungeon-only drops in the current design. Their catalog ids are `upgrade_chip`
and `alternate_chip`.

These resources must follow the normal dungeon completion protection:

- rewards are granted per eligible character completion;
- entry alone does not grant the resource;
- replay and duplicate reward requests must be idempotent;
- inventory-capacity failures must be explicit and recoverable;
- drop configuration must remain data-driven.

The equipment upgrade and reroll rules are defined in `ECONOMY.md`.

---

## Failure Rules

Players may fail or leave for different reasons.

Support explicit handling for:

- manual exit;
- timer expiration;
- party removal;
- party disband;
- disconnect cleanup;
- death handling if the dungeon design uses it.

Every failure path should return the player safely and clear stale instance state.

---

## Data Rules

Dungeon templates should remain data-driven and inspectable.

Prefer explicit template fields such as:

- `id`
- `display_name`
- `instance_spawn`
- `completion_rewards`
- `enemies`
- `boss`
- `exit_portal`

Keep the JSON understandable enough for balancing and design iteration without needing code changes for ordinary tuning.

---

## MMO Rules

Dungeons are high-risk for performance and abuse.

Always consider:

- instance count growth;
- enemy count per instance;
- reward replay exploits;
- party hopping abuse;
- reconnect behavior;
- timer snapshot cost;
- cleanup of empty or finished instances.

Do not design dungeons that assume unlimited instance density or perfect network conditions.

---

## Dungeon Checklist

Before adding a dungeon, answer:

1. What combat or progression purpose does it serve?
2. What is the success condition?
3. What creates failure pressure?
4. Why is it instanced instead of overworld?
5. How are rewards protected from abuse?
6. What happens on disconnect, timeout, or party changes?
7. Does it reinforce Datamoon combat identity?
