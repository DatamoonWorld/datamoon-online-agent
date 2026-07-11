# Datamoons Online - Quest Design

## Purpose

This document defines how quests should be designed and implemented in Datamoons Online.

Quests should:

- guide players through the world;
- teach systems;
- structure progression;
- create repeatable goals;
- connect lore, combat, and economy.

---

## Current Baseline

The active project already has a working quest flow with:

- quest definitions in server JSON;
- NPC-linked quest interactions;
- server-side acceptance and turn-in flow;
- mysqlapi-backed persistence;
- client quest snapshots and UI;
- repeatable and non-repeatable entries.

Current live examples include starter quests such as:

- `starter_nocmoon_hunt`
- `starter_nocmoon_fangs`

These are the baseline patterns to extend.

---

## Quest Identity

Quests should feel like guided MMO objectives inside the Datamoons world.

They are not only fetch lists.
They should reinforce:

- world onboarding;
- Datamoon ecosystem understanding;
- combat learning;
- economy loops;
- social or dungeon preparation;
- progression pacing.

---

## Quest Structure

Quest definitions should remain data-driven.

The current structure already supports:

- `id`
- `title`
- `description`
- `giver_npc_id`
- `turn_in_npc_id`
- `repeatable`
- `required_level`
- `requires_quests`
- `objectives`
- `rewards`

New quest work should preserve this explicit, inspectable format.

---

## Objective Rules

### Good objective categories

Use objectives that map cleanly to server-observable actions, such as:

- defeating a target Datamoon type;
- collecting a specific item;
- using a world interaction point;
- entering or clearing a dungeon;
- delivering crafted or gathered materials;
- interacting with a specific NPC.

### Objective design principles

- Objectives must be easy for the server to validate.
- Objectives should be readable in the UI.
- Objectives should avoid vague wording such as "explore more" unless tied to explicit triggers.
- Objectives should teach one thing at a time in early progression.

### Current safe baseline

The current codebase already establishes patterns like:

- `kill_enemy_type`
- `collect_item`

New objective types should be added carefully and only when the server can validate them cleanly.

---

## Reward Rules

Quest rewards may include:

- Bits;
- items;
- Datamoon XP;
- Link EXP;
- future reputation or access rewards.

Quest rewards should match the purpose of the quest.

Examples:

- tutorial quests should teach flow and give practical starter rewards;
- repeatable material loops should give moderate economic rewards;
- milestone quests should unlock progression or meaningfully increase power.

Do not make every quest reward all systems at once.

---

## Progression Rules

Quests should be layered.

Recommended structure:

- onboarding quests;
- local zone quest chains;
- system unlock quests;
- repeatable economy quests;
- dungeon preparation quests;
- faction, guild, or event quest lines later.

`requires_quests` should be used to shape coherent progression, not just arbitrary blocking.

`required_level` should gate difficulty, not hide basic usability.

---

## Repeatable Quest Rules

Repeatables are useful for ongoing loops, but they are high-risk for economy abuse.

Use repeatables for:

- material farming loops;
- zone mastery loops;
- event participation loops;
- daily or reset-based structures if added later.

Do not use repeatables when:

- the reward is too strong for infinite repetition;
- the objective can be botted easily;
- the loop bypasses the main progression systems.

---

## NPC Interaction Rules

Quest NPCs should be explicit service anchors.

Current patterns already show:

- quest-specific NPC ids;
- proximity checks;
- server validation on interaction;
- quest snapshot refresh after action.

Keep quest requests tied to the correct NPC whenever the design depends on location or narrative context.

---

## UX Rules

A quest should communicate:

- what to do;
- where to do it;
- what blocks it;
- whether it is available, active, or ready to turn in;
- what the reward is worth.

The client can format and localize this, but the server should still send clean state.

Error messaging should remain specific when possible, such as:

- locked by level;
- locked by prerequisite quest;
- wrong NPC;
- objective not complete.

---

## MMO Rules

Quest design must respect multiplayer realities.

Always consider:

- kill credit rules;
- party participation;
- contested targets;
- retry behavior after disconnect;
- repeatable spam;
- snapshot refresh cost.

If a quest requires combat or dungeon progress, define exactly who receives credit and when.

---

## Implementation Rules

When implementing quests:

- keep quest logic server-authoritative;
- persist meaningful quest state through mysqlapi;
- avoid client-side completion trust;
- favor explicit reward payloads;
- keep definitions data-driven in JSON;
- add new quest types only with validation logic and player feedback paths;
- update `docs/DECISION_LOG.md` when a new quest framework changes project-wide defaults.

---

## Quest Checklist

Before adding a quest, answer:

1. What player behavior does it teach or reward?
2. Can the server validate every objective?
3. Is the reward economically safe?
4. Is it repeatable, and if so, why?
5. Does it require a specific NPC or location?
6. Does it connect to combat, world, or Datamoon identity?
