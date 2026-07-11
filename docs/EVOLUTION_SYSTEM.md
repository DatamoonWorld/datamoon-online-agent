# Evolution System

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

## First Official Line

The first official evolution line for implementation and validation is:

- `Nocmoon -> Kainemoon -> Bathorymoon`

Stage mapping:

- `Nocmoon`: `Code`
- `Kainemoon`: `Nex`
- `Bathorymoon`: `Omega`

---

## Recommended Storage Shape

Persistent unlock storage should be modeled by Datamoon instance, for example:

- `datamoon_id`
- `base_type`
- `line_id`
- `form_type`
- `stage_index`
- `unlocked_at`

Recommended semantics:

- base `Code` form is implicit and does not need an unlock row;
- `Nex` is stage `1`;
- `Omega` is stage `2`;
- later forms or alternate lines can extend the same model.

---

## Initial Delivery Order

1. Document the system and official line in the agent.
2. Create the evolution catalog JSON for the first family.
3. Add mysqlapi migration and endpoints for unlock persistence.
4. Implement runtime transform/regress on the server.
5. Add minimal client UI for unlock and transform states.
