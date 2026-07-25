# Datamoons Online - Quest Authoring Template

## Purpose

Use this guide when creating quest definitions for the server.

Quest files live under:

```text
datamoon-online-server/utils/jsons/quests/
```

Definitions are data-driven, but an objective only works when the server has an
authoritative event that advances it. Do not add a new objective type only to
JSON and assume it is implemented.

## Current Functional Contract

The current quest runtime supports these objective types:

| Type | `target_id` | Progress source | Turn-in behavior |
| --- | --- | --- | --- |
| `kill_enemy_type` | Exact enemy type, such as `Slimmoon` | Server-confirmed enemy defeat | Progress is persisted as enemies die |
| `collect_item` | Exact item id, such as `nocmoon_fang` | Current authoritative inventory quantity | Required items are consumed atomically at turn-in |

The current reward types are:

| Type | Required fields | Result |
| --- | --- | --- |
| `bits` | `amount` | Grants Bits |
| `item` | `itemid`, `amount` | Grants an inventory item |
| `datamoon_xp` | `amount` | Grants XP to the active Datamoon |

The following planned beta objectives are not implemented yet:

- speaking to a specific NPC;
- interacting with Hatchery, Craft/Cooking or Archive;
- reaching or interacting with a portal;
- entering a dungeon;
- completing a dungeon or defeating its boss as a dungeon objective.

These require explicit server-side objective types and event hooks before their
quest JSONs can become functional.

## Copyable JSON

JSON does not support comments. Replace every `template_*` value before adding
the file to the server catalog.

```json
{
  "quests": [
    {
      "id": "template_zone_step_01",
      "title": "Quest title shown to the player",
      "description": "Clear instruction describing what to do and where to return.",
      "giver_npc_id": "template_quest_npc",
      "turn_in_npc_id": "template_quest_npc",
      "repeatable": false,
      "required_level": 0,
      "requires_quests": [],
      "objectives": [
        {
          "id": "kill_template_enemy",
          "type": "kill_enemy_type",
          "target_id": "TemplateEnemy",
          "required": 3,
          "label": "Defeat TemplateEnemy"
        }
      ],
      "rewards": [
        {
          "type": "bits",
          "amount": 100
        },
        {
          "type": "item",
          "itemid": "template_item",
          "amount": 1
        },
        {
          "type": "datamoon_xp",
          "amount": 100
        }
      ]
    }
  ]
}
```

Remove reward entries that the quest should not grant. A quest does not need to
grant every supported reward type.

## Linear Chain Pattern

The first quest has no prerequisite:

```json
"requires_quests": []
```

Every following quest names the immediately previous quest:

```json
"requires_quests": ["beta_q01_welcome"]
```

For a ten-quest linear chain:

```text
Q01: []
Q02: ["beta_q01_welcome"]
Q03: ["beta_q02_hatching"]
Q04: ["beta_q03_craft"]
Q05: ["beta_q04_cooking"]
Q06: ["beta_q05_archive"]
Q07: ["beta_q06_combat_basics"]
Q08: ["beta_q07_slimmoon_control"]
Q09: ["beta_q08_nocmoon_control"]
Q10: ["beta_q09_dungeon_portal"]
```

Do not point every quest directly to Q01. Referencing the previous step makes
the intended sequence explicit and prevents skipping an intermediate quest.

## Field Rules

### Quest

- `id`: unique, stable, lowercase snake_case identifier. Never reuse an id for
  a different quest after it reaches a persistent environment.
- `title`: short player-facing title.
- `description`: actionable instruction, including location or return NPC when
  useful.
- `giver_npc_id`: exact `npc_id` that may accept the quest.
- `turn_in_npc_id`: exact `npc_id` that may complete the quest.
- `repeatable`: keep `false` for the initial story chain.
- `required_level`: minimum active Datamoon level used by the current flow.
- `requires_quests`: ids that must already be completed.
- `objectives`: one or more server-observable objectives.
- `rewards`: economically reviewed rewards applied during completion.

### Objective

- `id`: unique inside the quest and stable after release.
- `type`: one of the implemented objective types.
- `target_id`: exact catalog or runtime id expected by that type.
- `required`: positive integer.
- `label`: concise progress text shown by the client.

### Reward

- Every `amount` must be a positive integer.
- An `item` reward must reference an existing item catalog id.
- Keep tutorial rewards practical and small.
- Avoid making story quests repeatable merely to permit retesting.

## NPC Definition

The quest giver/turn-in id must exist in the NPC catalog. A minimal quest NPC
uses this structure:

```json
{
  "npc_id": "template_quest_npc",
  "name": "OBJNPC_TEMPLATE_QUEST",
  "nickname": "Quest NPC",
  "sprite": "template_npc",
  "position": {
    "x": 20,
    "y": 20
  },
  "interact_radius": 32.0,
  "entry_message": "I have work for you.",
  "dialogue": [
    "First dialogue line.",
    "Second dialogue line."
  ],
  "primary_service_id": "quests",
  "services": [
    {
      "service_id": "quests",
      "label": "Quests",
      "prompt": "Review available assignments.",
      "auto_open": true
    }
  ]
}
```

`entry_message` and `dialogue` belong to the NPC interaction definition, not to
the quest definition. Quest-specific dialogue states are not currently modeled
inside the quest JSON.

## Runtime Lifecycle

Each non-repeatable quest moves through:

```text
locked -> available -> active -> ready_to_turn_in -> completed
```

- `locked`: required level or prerequisite quest is missing.
- `available`: the correct NPC may accept it.
- `active`: accepted and incomplete.
- `ready_to_turn_in`: all objectives are complete.
- `completed`: turn-in and reward operation succeeded.

Completion is server-authoritative. The client displays snapshots and sends
requests, but it does not decide progress or rewards.

## Creation Checklist

Before testing each quest:

1. Confirm the quest id is unique.
2. Confirm giver and turn-in NPC ids exist.
3. Confirm every prerequisite quest id exists.
4. Confirm every objective type has a server event hook.
5. Confirm enemy names and item ids match their catalogs exactly.
6. Confirm rewards reference valid items and safe amounts.
7. Accept the quest only at its configured giver.
8. Verify progress survives reconnect.
9. Verify turn-in fails at the wrong NPC and before completion.
10. Verify rewards and collected-item consumption happen only once.
11. Verify the next quest becomes available.
12. Run the server catalog validation before deployment.

## Initial Beta Authoring Boundary

Q07 and Q08 can be authored now with `kill_enemy_type`.

Q01-Q06, Q09 and Q10 should have their narrative, ids, NPCs, rewards and
prerequisites drafted now, but their functional JSON should wait until the
corresponding interaction and dungeon objective types are implemented.

## Planned Dialogue Quest Contract

Status: accepted design, not implemented.

A dialogue quest remains associated with its required NPC. Accepting the quest
does not complete its dialogue objective.

Expected flow:

1. The player interacts with the configured giver and accepts the quest.
2. The quest becomes `active` and remains listed by that NPC as in progress.
3. Selecting the active quest starts its quest-specific dialogue.
4. Advancing through intermediate dialogue lines does not persist progress.
5. The final dialogue balloon exposes a `Complete` action.
6. Only that final action requests completion from the server.
7. The server validates the character, active quest, NPC id, proximity and
   current dialogue session before applying completion and rewards.

Leaving interaction range, closing the dialogue/window, disconnecting or
changing NPC cancels the temporary dialogue session. The quest remains active
and the dialogue restarts from its first line on the next interaction.

The intended future definition is:

```json
{
  "objectives": [
    {
      "id": "learn_about_hatchery",
      "type": "talk_to_npc",
      "target_id": "quest_devmoon",
      "required": 1,
      "label": "Learn about the Hatchery"
    }
  ],
  "completion_mode": "dialogue_complete",
  "dialogue": {
    "speaker_npc_id": "quest_devmoon",
    "lines": [
      "DataEggs contain the pattern of a Datamoon.",
      "The Hatchery safely reconstructs that pattern.",
      "Use it whenever you are ready to hatch a new companion."
    ],
    "final_action": "complete"
  }
}
```

These fields are documentation only until `talk_to_npc`, dialogue sessions and
the final server RPC are implemented.

### Dialogue Authority Rules

- The client may render balloons, but it cannot mark the quest complete.
- The server owns the active NPC interaction and distance validation.
- A dialogue session is ephemeral and bound to character, quest and NPC.
- The final request must be safe to retry and must not grant rewards twice.
- Closing a UI is never equivalent to completing dialogue.
- Reading cannot be technically proven; the authoritative event is the valid
  final acknowledgement while the player remains eligible and in range.

## Planned Dungeon Quest Contract

Status: accepted design, not implemented.

Dungeon quests use a server-observed objective:

```json
{
  "objectives": [
    {
      "id": "complete_beta_dungeon",
      "type": "complete_dungeon",
      "target_id": "dungeon_1",
      "required": 1,
      "label": "Complete Dungeon 1"
    }
  ],
  "completion_mode": "automatic"
}
```

The authoritative order is:

```text
dungeon completion accepted
-> daily completion recorded
-> dungeon reward operation succeeds
-> complete_dungeon event advances matching active quests
-> automatic quests complete and grant their own rewards
-> client receives refreshed quest and inventory snapshots
```

The dungeon event must not fire when the dungeon reward fails or is rolled
back. Its event/operation identity must be stable so retries cannot advance or
reward a quest twice.

Every active quest whose `complete_dungeon.target_id` matches the completed
template may receive credit. Quests with `completion_mode = "automatic"` finish
without returning to an NPC; a future `npc_turn_in` mode may require a separate
turn-in after the objective becomes ready.
