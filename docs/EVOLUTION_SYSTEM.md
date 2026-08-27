# Evolution System

> This document defines the evolution contract. Current implementation status,
> priorities and pending work live only in `FIRST_BETA_ROADMAP.md`.

## Purpose

This document defines the v1 baseline for Datamoon evolutions.

It exists to align:

- lore registration;
- runtime transformation rules;
- persistence rules;
- UI states;
- future implementation order across server, mysqlapi, client, and agent docs.

---

## Core Model

- Every Datamoon family has a base `Code` form.
- A family may have one or more evolution lines.
- Each line is ordered and progression is sequential.
- Unlock state is persistent.
- Active transformed state is temporary session state in v1.

---

## Terms

- `Code`: base form.
- `Nex`: intermediate evolution stage.
- `Omega`: advanced evolution stage.
- `Unlock`: permanently enables a form for a specific Datamoon instance.
- `Transform`: temporarily switches the active runtime form while online.
- `Regress`: returns the Datamoon to its base `Code` form.

---

## Persistence Rules

- Unlocks persist by `datamoon_id`.
- Active transformed form does not persist in v1.
- On logout/login, the Datamoon returns to `Code`.
- On death, the Datamoon returns to `Code`.

This means:

- progression is permanent;
- active form is temporary.

---

## Unlock Rules

- A form can only be unlocked if its requirements are met.
- Supported requirement patterns for v1:
  - `level + item + link_level`
  - `link_level + item`
- Items are consumed only when unlocking.
- Unlock order inside a line is sequential.

Sequential rule:

- If `Nex` is not unlocked, `Omega` cannot be unlocked, even if the player already has the required items and levels.

---

## Transform Rules

- Transformation can happen in the overworld, during combat and inside a
  dungeon.
- A defeated Datamoon cannot transform.
- A new Transform/Regress request is rejected while a basic attack, skill or
  another evolution transition is active.
- Transform and Regress use a two-second authoritative action lock.
- A three-second cooldown starts when the transition completes and applies to
  every later Transform or Regress request.
- The Client exposes nine form slots above the combat hotbar. Their keyboard
  contract is `ALT+1` through `ALT+9`.

On successful transform:

- HP is restored to full.
- MP is restored to full.
- Buffs remain active.
- Skill cooldowns remain active by `skill_id`, even when the skill is not
  present in the destination form; they are restored when that skill becomes
  active again.
- equipment and Link modifiers are recalculated before HP and MP are filled;
- the persistent hotbar layout remains, while skill actions are resolved again
  from the active form's combat slots.

Regress follows the same resource, cooldown and hotbar rules. Death performs
an automatic Regress to Code without healing the defeated Datamoon; the normal
revive lifecycle owns the later resource restoration.

## Archive Rules

- Archive storage never persists `active_form_id`.
- A Datamoon stored from `Nex` or `Omega` is normalized to its base `Code`
  runtime form before the old entity is discarded.
- A Datamoon retrieved from the Archive is spawned in its base `Code` form.
- Unlocks, Link, XP, persistent effects and skill cooldowns remain attached to
  the Datamoon instance.
- HP and MP are restored to their maximum values when a Datamoon is retrieved.
- A failed swap rolls back the persistence operation and may restore the
  previous runtime entity without losing its temporary form.

---

## Branching Rules

- A Datamoon family may support more than one line.
- To move from one line to another, the Datamoon must first regress to `Code`.
- A later implementation may support line-specific Omega choices, but v1 should keep the rule simple and explicit.

---

## UI States

The initial UI should expose the following states for each form:

- `locked`
- `unlockable`
- `unlocked`
- `active`

Interpretation:

- `locked`: requirements are not met.
- `unlockable`: all unlock requirements are met and the form can be unlocked now.
- `unlocked`: the form has already been permanently unlocked and can be activated.
- `active`: the form is currently the active runtime form.

---

## Implementation Baseline

The current project structure favors:

- one server scene per form;
- one client scene per form;
- one species JSON per form;
- one evolution catalog entry per family.

This is preferred because forms may differ in:

- hitbox/hurtbox layout;
- skills;
- stats;
- sprite and animation setup;
- combat behavior details.

Until a form owns complete mirrored Client and Server scenes, its catalog can
remain runtime-incomplete. The runtime still applies its authoritative stats
and skills, but explicitly reuses the Code visual and valid Code timing as a
temporary content fallback. Set `runtime_ready` only after both projects have
the final scene, sprite, collisions and action timings.

---

## First Reference Line

The Slimmoon family is the first authoritative Unlock implementation:

- `Slimmoon`: `Code`;
- `Slimmoon Fighter Mode` (`slimmoon_fm`): `Nex`, requiring level 20, Link 3,
  and one `sword_blueprint`;
- `Slimmoon Warrior Mode` (`slimmoon_wm`): `Omega`, requiring the Nex unlock,
  level 60, Link 6, and one `armor_blueprint`.

Line identifiers always use the final Omega form. Therefore the registered
line is `slimmoon_wm`, not an arbitrary branch name. A future alternate branch
ending in `slimmoon_am` must use `slimmoon_am` as its line identifier.

The Server exports every registered line in `evolution_lines`. The Client keeps
a selected line and can switch that selection without changing authoritative
state. A visible line selector is required when more than one line exists.

The Stats evolution slots use these controls:

- right click on a locked form requests Unlock after every requirement is met;
- the confirmation explicitly authorizes permanent material consumption;
- left click on an unlocked form requests Transform or Regress under the
  authoritative runtime and animation contract.

Locked-form tooltips show live requirement status for level, Link, previous
form and inventory materials. Colors are informational only; the mysqlapi
revalidates ownership, progression, sequential unlocks and materials inside the
authoritative transaction.

---

## Transform Persistence Contract

Unlock storage remains modeled by Datamoon instance:

- `datamoon_id`
- `base_type`
- `line_id`
- `form_type`
- `stage_index`
- `unlocked_at`

Active form is session-only state owned by the Game Server. It is not written
to MySQL and requires no migration. The existing `dm_datamoons.type` remains
the permanent Code identity; runtime checkpoints persist resources and
progress without changing that identity. Login always rebuilds the Datamoon in
Code form.

Recommended semantics:

- base `Code` form is implicit and does not need an unlock row;
- `Nex` is stage `1`;
- `Omega` is stage `2`;
- later forms or alternate lines can extend the same model.

---

Implementation status and delivery order live only in
`FIRST_BETA_ROADMAP.md`.
