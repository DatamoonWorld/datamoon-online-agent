# Datamoons Online - Quest Design

> This document defines the quest-authoring contract. Current implementation
> status, priorities and pending work live only in `FIRST_BETA_ROADMAP.md`.

## Purpose

This document defines how quests should be designed and implemented in Datamoons Online.

Quests should:

- guide players through the world;
- teach systems;
- structure progression;
- create repeatable goals;
- connect lore, combat, and economy.

## Canon Narrative Placement

The starter Devmoon quests introduce the canon gradually. They should not
reveal the full history of the Adormecido, Voss, NULL Protocol or Data Bleed
before those events become relevant in the story.

All seven current starter Devmoon quests are authored with
`category: main` and `repeatable: false`. They form one persistent narrative
chain; future optional content must use `side` or a recurring category rather
than relying on the category fallback.

- Q1 presents Digital Center as the bridge between the human world and
  Dataworld. Node terminology remains Devmoon's technical vocabulary.
- Q2 explains that Datamoons are hybrid life forms born from the dreams of the
  Ser da Lua, without resolving the entity's true name or origin in Oberon.
- Q3 teaches the three Data Types, the first Link and combat equipment.
- Q4 introduces Moonlight Forest, NODE-01's first natural region, through the
  Slimmoon population and basic ecology.
- Q5 introduces Nocmoon, territorial behavior and the first signs that the
  region contains more than ordinary wildlife.
- Q6 presents Moonlight Depths as the first dungeon and the first place where
  unstable energy and deeper regional mysteries become visible. The current
  runtime ID is `moonlight_depths`.
- Q7 explains Link progression and the Code -> Nex -> Omega structure. The
  truth about Glitch Controlado remains a later revelation.

These are documentation-level dialogue directions. Localized Client strings
and quest JSON are not changed by this contract update.

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
- `category`
- `giver_npc_id`
- `turn_in_npc_id`
- `repeatable`
- `required_level`
- `requires_quests`
- `objectives`
- `rewards`

`category` is content metadata and may be `main`, `side`, `daily`, `weekly`,
`event` or `battle_pass`. The runtime exposes the category and availability to
the Client. `one_time`, legacy `repeatable`, `daily` and `weekly` are active;
event and battle-pass cycles remain reserved for a later system.

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

The current codebase establishes server-observable patterns including:

- `talk_to_npc`
- `kill_enemy_type`
- `collect_item`
- `complete_dungeon`

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

When authored progression says `level A -> B`, `A` is the quest's
`required_level` and the `datamoon_xp` reward is:

```text
total_xp_for_level(B) - total_xp_for_level(A)
```

This fixed reward is calculated from the canonical Datamoon XP curve. It moves
a Datamoon from the start of level A to the start of level B. Existing partial
XP is preserved and may carry the Datamoon beyond B.

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

## Party Credit Rules

Quest credit is determined by objective type, never by the Client:

- `collect_item`: each character must collect the items personally. Item drops
  are granted only to the character credited with the kill.
- `kill_enemy_type`: every online member of the same Party in the same
  `space_id` and worker receives kill progress.
- `complete_dungeon`: progress is granted when the dungeon instance is
  completed, to the members that receive the completion event. Killing the boss
  alone does not complete this objective.
- `talk_to_npc`: only the character performing the validated interaction gets
  progress.

A quest that must specifically require a boss kill should use
`kill_enemy_type` with the boss's authoritative type. It must not rely on the
dungeon completion event.

## Availability Policies

Quest categories and availability are intentionally separate. Recurring content
uses an explicit policy such as:

```json
"category": "daily",
"availability_mode": "daily"
```

The Server derives the current cycle key from UTC and persists it with the
character quest run. A unique `(character, quest, cycle_key)` identity prevents
duplicate rewards after retries or reconnects. Daily quests reset at the same
configured UTC hour as dungeons (currently 03:00 UTC). Weekly quests use the
same boundary and start on Monday. The Client receives `cycle_key` and
`next_reset_at_unix`, but never decides availability from its own clock.

Definitions without `availability_mode` inherit `daily` or `weekly` from their
category. New recurring content should still declare the mode explicitly.
Old cycle rows remain auditable in MySQL, while runtime snapshots request only
`permanent` plus the current daily and weekly keys.

Recommended categories are `main` for the narrative chain, `side` for optional
content, `daily` and `weekly` for reset-based loops, `event` for bounded world
windows, and `battle_pass` for season-owned progression. These categories do
not bypass normal Server validation or reward idempotency.

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

The global Quest Log lists only accepted quests that are still `active` or
`ready_to_turn_in`. It reuses the standard quest row, shows localized
description and authoritative objective progress, and permits abandonment
without requiring NPC proximity. Accepting, dialogue completion and turn-in
still require the correct NPC context.

The NPC board and quest indicator hide quests while either the active Datamoon
level or a prerequisite quest keeps them locked.

Abandoning removes the persisted quest row and objective progress. A
non-repeatable quest may then be accepted again if its level and prerequisite
requirements remain satisfied.

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
