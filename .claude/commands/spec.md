---
description: Open a new spec layer — the question, the hypothesis, tiered success criteria against a baseline, and the lever registry. Never overwrites an existing spec.
argument-hint: "[what this layer is about]"
---

Invoke the `spec-driven-development` skill.

**Never write to root `SPEC.md`** (the stale archived PocketScope spec) **or any existing spec file.**
Specs layer; they are not edited in place.

Output path:
- scoped to one subproject → `<subproject>/SPEC-<layer>.md`
- redefines a generation, or spans subprojects → root `SPEC-<gen>.md`
- a direction change inside the active generation → a dated `⟐ CURRENT DIRECTION (<date>)` top-block
  in the active spec, superseding the sections it replaces **by number**, leaving them in place

If the resolved path already exists, stop and ask for a new layer name.

Do not ask about users, features, or tech stack. Ask: the question · the hypothesis and what falsifies
it · the judge (number, data, baseline, margin) · what is frozen going in · model layer or investigation.

Stop at `DRAFT` and print the decision diff. Write no plan. Do not edit any `CLAUDE.md`.
