# Datamoons Online - Combat System

## Purpose

This document defines the combat direction for Datamoons Online.

Combat must support:

- real-time action;
- direct player control;
- online multiplayer;
- server authority;
- clear class and Datamoon identity;
- room for skill expression without breaking MMO scalability.

Combat is not a background automation system.
It is one of the main pillars of the project.

---

## Core Combat Identity

Combat in Datamoons Online is built around dual control:

- the player-controlled human character;
- the active Datamoon.

The player must be able to meaningfully switch between those roles.
If controlling a Datamoon feels equivalent to triggering a pet skill from a hotbar, the system has failed its core fantasy.

The combat loop should emphasize:

- positioning;
- timing;
- cooldown commitment;
- directional abilities;
- threat and exposure;
- role distinction between human and Datamoon.

---

## Combat Structure

### Human Character

The human character is the tactical anchor.

Typical responsibilities:

- movement and positioning;
- initiating encounters;
- using support tools;
- interacting with world objects;
- creating space, setup, or pressure for the active Datamoon.

The human should not overshadow the Datamoon in raw identity, but should remain mechanically relevant at all times.

### Active Datamoon

The active Datamoon is the primary expression of combat identity.

Typical responsibilities:

- skill execution;
- elemental or type pressure;
- core damage patterns;
- control effects;
- combat role specialization;
- evolution of playstyle through progression.

The Datamoon should feel more committed, more expressive, and more mechanically distinct than a simple summoned companion.

---

## Authority Model

Combat is server-authoritative.

The server must own or validate:

- hit confirmation;
- damage application;
- buffs and debuffs;
- cooldown legality;
- status effects;
- death or incapacity states;
- reward outcomes;
- combat-related progression.

The client may handle:

- input collection;
- animation;
- VFX and SFX;
- interpolation;
- short-lived prediction where needed;
- local UI feedback.

The client must not be the final authority for combat outcomes.

---

## Combat Design Rules

### 1. Control must justify itself

Direct control of a Datamoon must create decisions the player could not get from passive automation alone.

Good examples:

- aiming a dash or cone skill;
- choosing when to overextend for damage;
- switching targets under pressure;
- holding a cooldown for a counter-window;
- repositioning to exploit type advantage.

### 2. Readability matters

Even with multiple players and Datamoons on screen, combat must remain readable.

Favor:

- explicit telegraphs;
- short, readable effect durations;
- disciplined hitbox sizes;
- clear state transitions;
- restrained effect spam.

### 3. Commitment creates meaning

The strongest actions should create vulnerability, timing windows, or opportunity cost.

Avoid combat where every important action is instant, safe, and low-commitment.

### 4. MMO scale is a hard constraint

Every combat system must still work with multiple simultaneous players in a shared space.

Avoid solutions that depend on:

- excessive per-frame persistence;
- large unbounded RPC payloads;
- client-only state resolution;
- high-frequency authoritative full-state broadcasts.

---

## Ability Categories

Each Datamoon kit should usually be composed from a mix of these categories:

- basic attack;
- mobility skill;
- pressure skill;
- control skill;
- utility or setup skill;
- signature identity skill.

Not every Datamoon needs every category equally, but every kit should answer:

- how it starts pressure;
- how it sustains pressure;
- how it escapes or repositions;
- what makes it different.

---

## Status Effects

Status effects should be intentionally limited and categorized.

Recommended categories:

- damage over time;
- slow;
- root or short control;
- vulnerability amplification;
- defensive shielding;
- offensive buff;
- utility marker or conditional state.

Status effects should never become unreadable bookkeeping noise.

---

## Targeting And Hit Logic

Preferred patterns:

- directional skillshots;
- area skills with clear shapes;
- short-range melee arcs;
- triggered proximity effects;
- movement-linked attacks.

Avoid overusing:

- guaranteed full-screen effects;
- auto-targeting that removes player intent;
- chain effects with weak telegraphs;
- hit logic that is hard to validate on the server.

---

## Damage Formula Contract

Basic attacks and skills share the same defensive damage baseline.

The current baseline formula is:

```text
damage_before_modifiers = (power * 100) / ((DEF * 2.5) + 100)
```

### Basic attacks

Basic attacks always use the standard combat formula.

```text
power = ATK
damage = formula_base(power, DEF)
damage *= type_advantage
damage *= level_gap
damage *= variance
damage *= crit, if the basic attack crits
```

Critical chance and critical damage apply only to basic attacks.

### Skills

Every skill may define its own `damage_formula`.

The skill first builds a `power` value, then sends that value through the same defensive formula.

```text
power = damage + damage_inc * skill_level
power += ATK * atk_scale
power += HP * hp_scale
power += MP * mp_scale
power += DEF * def_scale
power += flat

damage = formula_base(power, DEF)
damage *= type_advantage
damage *= level_gap
damage *= variance
damage *= 1.0 + skill_damage
```

If a skill has no `damage_formula`, it falls back to:

```text
power = damage + damage_inc * skill_level
```

Skills do not crit.

`skill_damage` is a final float multiplier for skills. For example, `skill_damage = 1.5` means +150% final skill damage.

Armor penetration is intentionally reserved for a future pass and is not part of the current beta formula.

### Current beta examples

Slimmoon:

```text
power = base skill damage + growth + ATK * 1.0 + HP * 0.1
```

Nocmoon:

```text
power = base skill damage + growth + ATK * 2.5
```

---

## Progression And Balance

Combat growth should come from:

- new skill options;
- stronger role definition;
- better synergy with Link and progression systems;
- type and matchup mastery;
- situational build depth.

Do not rely only on raw stat inflation.

Balance should preserve:

- species identity;
- type identity;
- PvE readability;
- future PvP viability;
- room for counterplay.

---

## Integration With Other Systems

Combat must stay coherent with:

- `LINK_SYSTEM.md`
- `ADVANTAGE_SYSTEM.md`
- Datamoon species design;
- progression;
- world events;
- dungeon rules;
- inventory and equipment.

If a combat feature contradicts those systems, the contradiction should be resolved before implementation.

---

## Implementation Guidance

Before adding a combat mechanic, answer:

1. Is this human-facing, Datamoon-facing, or both?
2. Who owns the result: client, server, or shared visual layer?
3. What gets synchronized?
4. What can be predicted locally?
5. What is the abuse case?
6. How does this read in a crowded MMO scene?
7. What existing species or content does this invalidate?

---

## Current Direction

The current project direction should continue to favor:

- real-time skill-based combat;
- direct Datamoon control;
- server validation;
- modular skill and state logic;
- restrained but expressive combat feedback.
