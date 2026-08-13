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

- Transformation can happen anywhere.
- Transformation cannot happen while the Datamoon is in action.
- Examples of blocked states:
  - combat action;
  - skill cast;
  - fishing;
  - other gameplay gimmicks that mark the Datamoon as busy.

On successful transform:

- HP is restored to full.
- MP is restored to full.
- Buffs remain active.
- Skill cooldowns reset.

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

---

## First Implemented Line

The Slimmoon family is the first authoritative Unlock implementation:

- `Slimmoon`: `Code`;
- `Slimmoon Fighter Mode` (`slimmoon_fm`): `Nex`, requiring level 20, Link 3,
  and one `sword_blueprint`;
- `Slimmoon Warrior Mode` (`slimmoon_wm`): `Omega`, requiring the Nex unlock,
  level 60, Link 6, and one `armor_blueprint`.

Line identifiers always use the final Omega form. Therefore the registered
line is `slimmoon_wm`, not an arbitrary branch name. A future alternate branch
ending in `slimmoon_am` must use `slimmoon_am` as its line identifier.

Unlock persistence, item consumption, sequential validation, Link-cap
promotion and audit are implemented. Runtime Transform/Regress and the final
form scenes remain separate work.

The Server exports every registered line in `evolution_lines`; it no longer
discards branches after the first entry. The Client keeps a selected line and
can switch that selection without changing authoritative state. A visible line
selector is required only when a second line is registered.

The Stats evolution slots use these controls:

- right click on a locked form requests Unlock after every requirement is met;
- the confirmation explicitly authorizes permanent material consumption;
- left click on an unlocked form is reserved for Transform/Regress;
- Transform/Regress intentionally remains inactive until its authoritative
  runtime state and animation contract are implemented.

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

Before Transform/Regress is implemented, `dm_datamoons` must gain explicit
`family_id` and `active_form_id` fields. The existing `type` field must not be
repurposed because current progression and species contracts use it as the base
identity. That migration, its write paths and runtime scene swap are one atomic
delivery and remain deferred until the form sprites/scenes are ready.

Recommended semantics:

- base `Code` form is implicit and does not need an unlock row;
- `Nex` is stage `1`;
- `Omega` is stage `2`;
- later forms or alternate lines can extend the same model.

---

## Initial Delivery Order

1. Document the system and official line in the agent.
2. Create the evolution catalog JSON for the first family. (complete)
3. Add mysqlapi migration and endpoints for unlock persistence. (complete)
4. Add the minimal client Unlock interaction and persistent state. (complete)
5. Implement runtime Transform/Regress on the server. (pending)
6. Replicate and retain every branched line. (complete)
7. Add the visible branched-line selector before registering a second line. (pending)
