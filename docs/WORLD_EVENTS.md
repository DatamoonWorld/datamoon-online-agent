# Datamoons Online - World Events

## Purpose

This document defines the direction for world events in Datamoons Online.

World events should make the world feel reactive, social, and worth revisiting.

They should:

- create timed excitement;
- activate zones in meaningful ways;
- connect lore and gameplay;
- generate group movement across the map;
- provide structured economic and progression rewards.

---

## Event Identity

World events should feel native to Datamoons Online.

They should connect to:

- lunar cycles;
- data anomalies;
- corrupted zones;
- ecosystem shifts;
- faction or guild pressure later;
- Datacore, Patch, and Glitch energy patterns.

Events should never feel like unrelated seasonal wrappers pasted onto the world.

---

## Event Categories

Recommended categories:

- overworld spawn surges;
- corruption outbreaks;
- resource rush windows;
- portal anomalies;
- roaming elite or boss events;
- dungeon-linked preparation events;
- community progress events later.

Start with simple event forms before building global multi-phase structures.

---

## Authority Rules

World events are server-authoritative.

The server should own:

- event start and end;
- active zone state;
- spawn changes;
- interaction validity;
- reward distribution;
- cooldown or participation caps;
- cleanup on shutdown or restart where needed.

The client may display:

- timers;
- announcements;
- map markers;
- event UI;
- local VFX and feedback.

---

## Scope Rules

Not every event needs to be global.

Use one of these scopes:

- local zone event;
- shard-wide event;
- party-targeted event;
- dungeon-adjacent event.

Choose the smallest scope that achieves the design goal.
Smaller scopes are easier to scale and tune.

---

## Chunk And World Rules

Because the world is chunk-based and server-driven:

- event logic must not require loading the whole map on every client;
- spawn changes should be localized;
- broadcasts should reach affected players cleanly;
- join-in-progress players should receive correct event state when entering the area.

Events should integrate with chunk streaming and interest management instead of bypassing them.

---

## Reward Rules

Event rewards may include:

- Bits;
- items;
- crafting materials;
- type-aligned essences;
- Datamoon XP;
- Link EXP;
- future cosmetic or reputation rewards.

Event rewards should be strong enough to motivate participation, but not so strong that regular progression becomes irrelevant.

Avoid rewards that can be endlessly farmed without friction.

---

## Participation Rules

Define participation clearly.

Possible participation models:

- tag-and-contribute;
- objective completion;
- party contribution;
- proximity plus action validation;
- capped personal reward claims.

Do not rely on vague presence-only participation for high-value rewards.

---

## Anti-Abuse Rules

World events are especially vulnerable to:

- alt-account stacking;
- AFK tagging;
- spawn camping;
- reward replay;
- excessive server-wide broadcast spam;
- join/leave loopholes.

Use:

- explicit contribution rules;
- per-character reward locks where needed;
- safe spawn pacing;
- server-tracked eligibility;
- rate-limited announcements.

---

## Design Rules

### 1. Events should change player behavior

An event should make players go somewhere, prepare differently, or engage with a system in a new way.

### 2. Events should be readable

Players should understand:

- what is happening;
- where it is happening;
- how long it lasts;
- what they should do;
- why it matters.

### 3. Events should fit the world

If an event changes a zone, the lore, visuals, enemies, and rewards should point in the same direction.

---

## Rollout Guidance

Good early event candidates:

- boosted spawn windows in a zone;
- corruption wave with elite enemies;
- essence surge linked to one advantage type;
- dungeon key or access preparation event.

Avoid starting with:

- massive map-wide scripted events;
- highly cinematic sequences that fight the MMO runtime;
- fragile one-off logic that cannot be reused.

---

## Event Checklist

Before adding an event, answer:

1. What changes in the world during the event?
2. What is the player action loop?
3. How is participation validated?
4. What is the reward, and is it economically safe?
5. What is the event scope?
6. How does it behave with chunk streaming and reconnects?
7. Does it reinforce the Datamoons setting?
