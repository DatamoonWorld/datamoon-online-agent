# Datamoons Online - Dungeon Rules

## Purpose

This document defines the rules for instanced dungeons in Datamoons Online.

Dungeons should provide:

- focused combat challenges;
- party coordination opportunities;
- reward concentration;
- progression milestones;
- reusable endgame structure later.

---

## Current Baseline

The project already has a live dungeon template pattern.

Current implementation includes:

- data-driven dungeon templates in server JSON;
- dungeon entry and exit portals;
- per-instance space ids;
- instance timers;
- party-aware instance reuse;
- completion rewards;
- forced ejection on timeout or party invalidation.

`training_cavern` is the current reference template.

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

---

## Entry Rules

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
- `entry_portal`
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
