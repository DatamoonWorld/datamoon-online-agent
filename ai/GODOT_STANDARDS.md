# Datamoons Online - Godot Standards

## Purpose

This document defines practical Godot standards for the active Datamoons Online codebase.

It is meant to keep agents aligned with the current project conventions across client, auth, gateway, and server.

---

## Engine Baseline

Treat Godot 4.7 as the default project baseline.

For the current beta runtime context:

- local development has already moved to Godot `4.7.1 rc1`;
- VM gameplay services were aligned to Godot `4.7.1 rc1`;
- docs should still refer to the project baseline as Godot 4.7 unless a narrower runtime note matters.

Do not assume 4.6-era metadata or behavior is still the active default.

---

## Project Separation

There are multiple Godot projects in the workspace.

Keep their responsibilities separate:

- `datamoon-online-client`
- `datamoon-online-auth`
- `datamoon-online-gateway`
- `datamoon-online-server`

If a change touches shared network contracts or mirrored resources, update both sides deliberately.

---

## Headless Runtime Rules

Gameplay-side services run headless on the VM.

That means:

- avoid editor-only assumptions in runtime code;
- keep imports healthy after pulling updates on the VM;
- after project metadata changes, run a headless import pass before restart when needed;
- remember that runtime logs may be the first signal of parse or import breakage.

---

## Script Rules

Prefer:

- small, focused scripts by responsibility;
- explicit names;
- data-driven content for tuneable systems;
- server authority for gameplay logic;
- client-side scripts for UI and presentation concerns.

Avoid:

- hiding major authority in presentation scripts;
- giant utility files with unrelated responsibilities;
- duplicate function definitions;
- weakly justified global state.

---

## Signal Rules

Signals must match callable signatures exactly.

If a signal emits one argument, the connected method must accept one argument or route through a matching wrapper.

This matters because the project already hit a real issue from a language-change signal calling a zero-argument method.

When wiring signals:

- check emitted parameter count;
- prefer wrapper handlers when the UI refresh method takes no args;
- keep signal naming descriptive and narrow.

---

## Shared Contract Rules

Some Godot-side files are cross-repo contracts.

The biggest example is mirrored RPC surface definitions between client and server.

Treat these files as fragile coordination points:

- change them in lockstep;
- keep ordering stable;
- avoid convenience edits on only one side.

---

## Config Rules

Project config scripts should stay parse-safe and centralized.

When changing config-related logic:

- avoid duplicate method definitions;
- keep runtime host and version assumptions explicit;
- prefer one clear source for connection defaults;
- remember that config parse failures can block service boot.

---

## Scene And Content Rules

Prefer data-driven scene behavior where possible.

Good candidates:

- quests;
- dungeons;
- item definitions;
- recipes;
- enemy spawn tables;
- portal definitions.

Do not hardcode balance data in scattered gameplay scripts if the project already has a JSON content path for it.

---

## Compatibility Rules

When changing Godot metadata or runtime-sensitive files:

- think about local and VM parity;
- verify headless services still import and boot;
- verify client connection compatibility when RPC contracts change;
- avoid mixing branches or engine versions casually.

If a change can break startup, plan a verification step.

---

## Checklist

Before making a Godot-side change, answer:

1. Which Godot project owns this change?
2. Is it runtime logic, UI logic, or shared contract logic?
3. Could this break headless startup?
4. Does it affect mirrored client/server files?
5. Does it depend on a specific 4.7 behavior or metadata assumption?
