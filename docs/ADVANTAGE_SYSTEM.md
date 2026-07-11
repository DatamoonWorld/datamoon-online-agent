# Datamoons Online - Advantage System

## Purpose

This document defines the high-level rules for type advantage in Datamoons Online.

The system must:

- reinforce the identity of `Datacore`, `Patch`, and `Glitch`;
- stay readable for players;
- be strong enough to matter;
- be limited enough to avoid invalidating skill and build decisions.

---

## Fundamental Cycle

The base relationship is:

```text
Datacore > Patch
Patch > Glitch
Glitch > Datacore
```

This is both a mechanical rule and a lore rule.

It should be treated as a foundational axis of combat design, not a cosmetic label.

---

## Meaning Of Each Type

### Datacore

Represents:

- order;
- structure;
- memory;
- precision;
- stability.

Datacore advantage should feel like:

- disciplined pressure;
- reliable execution;
- structural superiority.

### Patch

Represents:

- adaptation;
- repair;
- refinement;
- integration;
- balance.

Patch advantage should feel like:

- correction;
- adjustment;
- controlled response to instability.

### Glitch

Represents:

- rupture;
- mutation;
- unpredictability;
- freedom;
- distortion.

Glitch advantage should feel like:

- destabilization;
- pressure through irregularity;
- forcing the opponent out of comfort.

---

## Design Rules

### 1. Advantage must matter, but not dominate

Type advantage should influence combat decisions, target selection, dungeon preparation, and team composition.

It should not make player execution irrelevant.

### 2. Counterplay must remain possible

A disadvantaged type should still win through:

- better positioning;
- better cooldown timing;
- stronger build choices;
- higher mastery;
- tactical support from the human character or team.

### 3. The cycle must stay simple

The core triangle should remain easy to remember.

If future systems add subtypes, influences, or anomalies, the base cycle must still remain legible.

---

## Recommended Mechanical Impact

The exact numeric tuning can evolve, but the effect should usually influence:

- damage dealt;
- damage received;
- status effect strength or duration;
- shield efficiency in limited cases;
- AI priority or behavior for PvE encounters.

Recommended starting principle:

- type advantage should be noticeable in normal play;
- it should not create instant unwinnable matchups;
- it should scale more through combat flow than through gigantic multipliers.

Avoid extreme values that reduce the system to rock-paper-scissors autopilot.

---

## Interaction With Combat Roles

Type advantage should not erase role identity.

Examples:

- a control-oriented Datamoon should still feel like a control-oriented Datamoon even in advantage;
- a burst Datamoon should still depend on windows and commitment;
- a support-oriented Datamoon should gain matchup value without becoming a damage outlier.

Type modifies role performance.
It does not replace role design.

---

## PvE Use

In PvE, advantage should encourage:

- preparing the right active Datamoon;
- rotating control intentionally;
- learning regional species patterns;
- building dungeon strategies.

Bosses and elites may:

- lean toward one type;
- shift between states;
- partially resist raw type exploitation;
- create mixed-pressure encounters that reward flexible teams.

---

## PvP Use

If PvP expands, the advantage system must:

- reward draft and team planning;
- create pressure without hard-locking outcomes;
- support spectator readability;
- avoid degenerate mirror-breaking multipliers.

If a player loses primarily because of type assignment before combat decisions happen, the tuning is too strong.

---

## Lore Consistency

Advantage is not arbitrary.

The cycle should be interpreted as:

- `Datacore` overwhelms `Patch` through stable structure;
- `Patch` corrects and redirects `Glitch`;
- `Glitch` breaks and disrupts `Datacore`.

Future Datamoon species, skills, and world phenomena should reflect those relationships.

---

## Implementation Guidance

When implementing or revising the system, answer:

1. Is the advantage applied on outgoing damage, incoming damage, or both?
2. Is the effect flat, multiplicative, or contextual?
3. Does the server own final calculation?
4. How is the result exposed to players?
5. Can the player understand why a matchup feels favorable or unfavorable?
6. Does the current value still allow skillful outplay?

---

## Current Recommendation

Use the triangle as a stable global rule.

Then layer depth through:

- skill kit design;
- Link progression;
- equipment and buffs;
- encounter scripting;
- species identity.

The advantage system should be foundational, readable, and intentionally limited.
