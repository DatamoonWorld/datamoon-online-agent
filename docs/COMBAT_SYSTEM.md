# Datamoons Online - Combat System

> This document defines the combat contract. Current implementation status,
> priorities and pending work live only in `FIRST_BETA_ROADMAP.md`.

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

When equipment or an equipment upgrade changes maximum HP or MP, the Server
preserves the absolute current value. Increasing the maximum does not grant HP
or MP; reducing it only clamps the current value to the new maximum. Recovery
must come from an authorized gameplay source such as regeneration or an item,
which prevents equipment changes from becoming a healing exploit.

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

## Enemy Behavior Contract

Enemy personality is selected by spawn `ai_behavior` and implemented by a
registered species behavior. Per-area group state coordinates members without
duplicating combat execution. Unknown ids use a defensive fallback and emit a
server warning.

Lifecycle, group state, AI decisions and action states are separate contracts.
Spawn and death block damage in both directions. Full architecture and the
authoring procedure live in `docs/ENEMY_AI.md`.

Enemy skill availability must be explicit:

```json
{
  "skill_slots": [],
  "skills_enabled": false
}
```

When `skills_enabled` is false, an empty slot list means no skills. When true,
an empty slot list may resolve all available species skills for compatibility.

---

## Damage Formula Contract

Basic attacks and skills share the same defensive damage baseline.

The current live server baseline formula is:

```text
DEFENSE_DAMAGE_SCALE = 2.5
damage_before_modifiers = (power * 100) / ((DEF * DEFENSE_DAMAGE_SCALE) + 100)
damage_before_modifiers = (power * 100) / ((DEF * 2.5) + 100)
```

### Basic attacks

Basic attacks always use the standard combat formula.

```text
power = ATK
damage = formula_base(power, DEF)
damage *= system_multiplier
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
damage *= system_multiplier
damage *= 1.0 + skill_damage
```

If a skill has no `damage_formula`, it falls back to:

```text
power = damage + damage_inc * skill_level
```

Skills do not crit.

`skill_damage` is a final float multiplier for skills. For example, `skill_damage = 1.5` means +150% final skill damage.

Damage does not use a random variance or a level-gap multiplier. Level still
matters because it increases effective stats through each species' stat growth,
but it does not apply a second hidden damage penalty or bonus.

Any valid damaging action with positive post-formula damage deals at least `1`.
Critical chance remains probabilistic and is not considered damage variance.

Armor penetration is intentionally reserved for a future pass and is not part of the current beta formula.

### Formula fallback contract

The skill formula and the shared defensive formula are separate concerns:

- a basic attack uses `ATK` as its power;
- a skill uses its own `damage`, `damage_inc`, and optional `damage_formula`;
- a skill without `damage_formula` does not fall back to `ATK`;
- both paths still use the shared defense and system-advantage calculations;
- only a basic attack can crit;
- final positive damage is deterministic apart from the separate critical roll.

Generated equipment stats are included in the live effective-stat calculation.
They are added with base and flat bonuses before multiplicative buffs. The full
progression contract is described in `ECONOMY.md`.

### Skill JSON contract

The standard formula needs no `damage_formula`. This skill uses only base damage
and Link/skill-level growth:

```json
{
  "slot": 2,
  "damage": 100,
  "damage_inc": 25,
  "mana_cost": 20,
  "cooldown": 4.0,
  "timing": {
    "fps": 12,
    "total_frames": 10,
    "impact_frame": 6,
    "impact_window_frames": 1
  },
  "buff_debuff": false
}
```

A custom formula adds any combination of the supported scale fields. Omitted
fields are zero:

```json
{
  "slot": 2,
  "damage": 100,
  "damage_inc": 60,
  "damage_formula": {
    "atk_scale": 1.0,
    "hp_scale": 0.1,
    "mp_scale": 0.0,
    "def_scale": 0.0,
    "flat": 0.0
  },
  "mana_cost": 30,
  "cooldown": 4.0,
  "timing": {
    "fps": 12,
    "total_frames": 12,
    "impact_frame": 7,
    "impact_window_frames": 1
  },
  "buff_debuff": false
}
```

The formula fields are coefficients, not percentages. `atk_scale = 1.5` adds
150% of effective ATK to power; `hp_scale = 0.1` adds 10% of effective maximum
HP. Equipment bonuses are part of those effective stats.

### Damage-over-time contract

Bleed, Poison and Burn use a percentage of the source's effective ATK:

```json
{
  "buff_debuff": true,
  "buff_debuff_id": "BLEED",
  "buff_debuff_bonus": 10.0,
  "buff_debuff_time": 5.0,
  "buff_debuff_data": {
    "dot_scaling": "source_atk_percent",
    "dot_attack_scale": 0.1,
    "stack_group": "skill",
    "persistence_mode": "active_only"
  }
}
```

`dot_attack_scale = 0.1` means 10% of effective ATK per tick. Effective ATK is
captured when the effect is applied. Later Attack Up, Attack Down, equipment or
other runtime changes do not modify an already-active DOT; they affect only a
new application.

When multiple applications of the same stackable DOT are active, only the
strongest captured tick deals damage. Weaker applications cannot evict or
replace, refresh or extend the strongest active value. An equal application also
leaves the existing DOT unchanged. Only a later application with higher
captured damage replaces the value and renews its duration. Persisted effects
retain this ATK snapshot even when their original source no longer exists.

### Conditional skill effects

Skills may define post-hit effects gated by target state:

```json
{
  "conditional_effects": [
    {
      "condition": {
        "type": "target_has_effect",
        "effect_id": "bleed"
      },
      "effect": {
        "type": "heal_self_from_damage",
        "scale": 0.2
      }
    }
  ]
}
```

This example heals the caster for 20% of damage actually dealt when the target
already had Bleed before the hit. A debuff applied by the same hit does not
retroactively satisfy the condition.

Conditions and effects are data-driven extension points. New condition/effect
types must be implemented and validated server-side before appearing in JSON.

### Equipment combat contract

- The Bracelet is mandatory for the active Datamoon to perform attacks.
- Bracelet, Hood, and Shoes bonuses apply only to the active Datamoon.
- Switching the active Datamoon reapplies the character's equipment bonuses.
- Equipment changes are rejected while the character is in combat.
- Outside combat, effective combat stats are recalculated immediately after an
  equipment change.

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

---

## Enemy Spawn Combat Configuration

`skill_slots` belongs to enemy AI and is independent from the player hotbar.
Values `2` through `5` select `SKILL_1` through `SKILL_4`. Omitting the field
or providing an empty array makes the enemy collect every skill available in
its scene. Set the field only when an enemy must use a restricted subset.

Enemy removal derives exclusively from `combat_timing.death`. At 12 FPS,
`"total_frames": 12` keeps the dead entity for one second before removing it.
`total_frames: 0` means that no death animation exists and removal is immediate.
Overworld respawn timing starts after removal, so the effective time is the
death frame duration plus `respawn_seconds`. The Server replicates the resolved
death duration and the Client keeps the entity fully opaque while presenting
the authored death animation; no independent visual delay is allowed.

Authoritative HP changes carry a monotonic `hp_version`. Clients must ignore an
HP snapshot or combat event whose version is older than the last version
applied to that entity. This applies to damage, healing, respawn, session
restore, equipment clamping, and enemy leash reset.

Boss instances additionally replicate `is_boss`, `boss_id`, `name_key`, and
`hud_distance`. These fields are encounter data, not species data, and never
modify another entity of the same species.

## Frame-Based Action Timing

Combat actions use one-based animation frames. The canonical configuration is:

```json
{
  "fps": 12,
  "total_frames": 6,
  "impact_frame": 4,
  "impact_window_frames": 1,
  "movement": {
    "start": {"mode": "free", "movement_multiplier": 1.0},
    "impact": {"mode": "reduced", "movement_multiplier": 0.5},
    "recovery": {"mode": "free", "movement_multiplier": 1.0}
  }
}
```

The Server converts frames to timers and remains authoritative over movement,
hitboxes, projectiles and damage. `start` covers frames before
`impact_frame`; `impact` covers `impact_window_frames`; all remaining frames
are `recovery`. Supported movement modes are `free`, `reduced` and `locked`.

`animation_speed`, `cast_time`, `impact_time`, `impact_ratio` and
`death_delay` are not part of the current contract. Species and skills without
positive `total_frames` cannot execute that action. `attack_speed` remains the
interval in seconds between basic-attack starts and does not control animation
duration.

The resolved frame contract and `action_start_input_tick` are included in
`combat_action_started`. Client and Server derive the movement phase from the
same input tick, animation FPS and physics tick rate. Locked phases still
advance the input sequence with zero displacement; commands are never discarded
only because a combat phase blocks movement.

The Client predicts the locally controlled entity, stores sequenced inputs and
replays only inputs newer than the Server acknowledgement. Other entities use
authoritative interpolation/presentation and are not locally resimulated.
Rendering correction is separate from simulation state and must not become an
input to later physics. HP loss, rewards, hits and cooldown legality remain
Server-authoritative.

Enemy XP and Link EXP use an explicit object contract:

```json
{
  "rewards": {
    "xp": {
      "base": 15,
      "multiply_by_enemy_level": true
    },
    "link_exp": {
      "base": 5,
      "multiply_by_enemy_level": true
    }
  }
}
```

Numeric enemy XP and Link EXP values are invalid. Reward calculation order is:

1. Resolve `base * enemy_level` when `multiply_by_enemy_level` is enabled.
2. Apply eligible party reward bonuses.
3. Apply the receiver-versus-enemy level-gap scale.

The level-gap scale grants 100% through five levels above the enemy, then loses
10 percentage points per additional level. A receiver fifteen or more levels
above the enemy receives zero XP and zero Link EXP.

Dungeon completion rewards are a separate contract. They are not enemy rewards
and are not multiplied by an enemy level.
