---
name: spec-driven-development
description: Open a new spec layer for a research question — hypothesis, evidence-graded causal chain, tiered success criteria against a named baseline, and a lever registry. Use when starting a new generation of work, changing direction, reframing a target, or specifying an investigation. Records what it supersedes and never overwrites an existing spec.
allowed-tools: Read Write Edit Bash Glob Grep
---

# Spec a research layer

A spec here states **what we are trying to find out, and how we will know**. It is not a product
requirements document. There are no users, no features, and no tech-stack survey.

Use the project's own vocabulary: `lever registry`, `measured`/`derived`/`open`, `Tier 0–3`,
`superseded`, `done-negative`, `void`.

## Rule 0 — never overwrite an existing spec

**Specs layer; they are not edited in place.** A new direction becomes a *new layer* (or a dated
top-block inside the active one) that names what it supersedes and keeps the old text as the record.

> `SPEC-gen3.md`: *"Everything below it … is **kept as the record** of how gen3 reached here — read it
> for the measured root-cause evidence, not for the current plan."*

**Two paths that must never be written to:**

| Path | What is actually there |
|---|---|
| `SPEC.md` (workspace root) | the **stale archived PocketScope spec** — `SPEC-gen3.md` says *"**Not** the stale root `SPEC.md`"* |
| `tasks/plan.md` (workspace root) | the **stale PocketScope plan** |

If the resolved output path already exists, **stop and ask for a new layer name.** Never pass a
heredoc, `>`, `Write`, or `sed -i` over a file in the layer chain.

## Step 1 — resolve the layer chain, and print it

Read the target project's `CLAUDE.md` block *"Full context, in layers (read in this order — later
files override earlier decisions)"*. **Read it; do not restate it here** — CLAUDE.md is the navigator
and the only source of truth for the chain.

Print the chain with what each layer closes, then name where the new layer sits. The shape to print —
one line per layer, its decision-id range, what it supersedes, and which one is active:

```
<base spec>              <ids>       the original decisions
  └ <layer 2>             <ids>       supersedes <which ids>
     └ <layer 3>          <ids>       supersedes <which ids>
        └ <layer 4>       <ids>       STOPPED — superseded for <what>
           └ <layer 5>    <ids>       ACTIVE  ← a new layer sits here
```

Where the chain is recorded, and which paths must never be written to, are in
`.claude/references/project-profile.md` → *Spec and task files*.

## Step 2 — pick the output path

- A layer scoped to **one subproject** → `<subproject>/SPEC-<layer>.md`
- A layer that **redefines a generation** or spans subprojects → root `SPEC-<gen>.md` (the gen2/gen3
  precedent)
- A **direction change inside the active generation** → a dated `⟐ CURRENT DIRECTION (<date>)`
  top-block in the active spec, superseding the sections it replaces by number, leaving them in place.
  This is what the 2026-10-21 frontend-redesign change did.

## Step 3 — ask only what you cannot read

Do **not** ask about users, features, or tech stack. Ask at most these, and skip any the repo answers:

1. **The question** — what do we not know, that this layer will settle?
2. **The hypothesis**, **what would falsify it**, and **whether anyone has already tested it**.
3. **The judge** — which number, on which data, against which baseline, and what margin counts.
   For an external baseline, also: which split and metric definition it was measured under.
4. **What is frozen going in** (do not reopen), and what this layer **closes** from the layer below.
5. **Model layer or investigation?** (or infer: does the target have `cli/train_*` and a trainer?)
   **Echo the choice.**

State assumptions before writing:

```
ASSUMPTIONS I'M MAKING:
1. ...
→ Correct me now or I'll proceed with these.
```

## Step 4 — write the layer

Use the matching template, which carries the real section list:

- **Model layer** → [`model-layer-template.md`](model-layer-template.md)
- **Investigation** → [`investigation-layer-template.md`](investigation-layer-template.md)

Non-negotiable content in either form:

- **The header block** — `Status:`, `Layers on:` (inherited files, what each **keeps** vs **closes**,
  by decision id), `Not` (the explicit exclusion list — this is the line that protects root `SPEC.md`),
  `What is frozen going in (do not reopen)`, and a **numbering bridge** paragraph for any id that is
  split or retired.
- **The causal chain**, every link tagged **`measured`** / **`derived`** / **`literature`** /
  **`assumption`** / **`open`**, with the evidence path for each. An inference written as a measurement
  is the failure to avoid. Rules: [`../../references/evidence-standards.md`](../../references/evidence-standards.md).
- **Prior work, and where this layer sits in it.** What has been published on this question, with each
  number's dataset, split and metric; what the field has tried and dropped; the known failure modes.
  If the hypothesis contradicts published work, say so and say what would settle it. If the literature
  already answers part of the question, that part is not an experiment — it is a citation.
  The 2026-10-21 direction change is the worked example: two papers (DSCA-HLAII, PLOS Comp Biol 2026;
  AIKI-HLA, bioRxiv 2026) reframed the problem as data-bound at ~0.765 per-allele-median AUROC and
  showed the headline 0.85–0.95 figures are mostly interpolation.
- **Tiered success criteria** — each check a number against a **bracketed baseline** it must beat, not
  a feature. Plus the **stop rule as a table** (`outcome → reading → next`).
- **The lever registry** — `id │ phase │ change │ why │ status`, then *Open sub-decisions (resolve in
  PLAN/at the arm, with evidence)*, then a **build order** in which a later phase is not judged while
  an earlier Tier-0 check still fails.
- **Boundaries** — Always / **Ask first** / Never, with spent and rejected approvals noted as on record.
- **Review policy** — which review dimensions exist for *this* project, and what each is for. The plan
  then assigns them per task on a `Review:` line, and `/build` runs what the task names. This is what
  makes the setup portable: a project with no domain-science component declares no `biology`
  dimension, and no task can assign one.

  ```markdown
  ## Review policy
  - `code` — correctness, fidelity to the reference implementation, attributability. Every task.
  - `biology` — does the code represent the biology it claims? Assign when a change touches residue
    slicing, chain handling, masking, or label/group semantics.
  - `scope` — only when the reviewing session did not build the change.
  ```

## Step 5 — stop at DRAFT

Write no plan. §10 stays a pointer to `tasks/plan-<gen>.md` + `todo-<gen>.md`.

Print the **decision diff** for sign-off: what this layer closes · what it re-opens · what it freezes ·
which ids it bridges. Then stop.

One pointer line in the target `CLAUDE.md` layers list is now stale. **Do not edit CLAUDE.md** — print
the exact one-line edit and hand it over, or leave it to the `handoff` skill, which owns navigator edits.

## Failure modes

- Writing to root `SPEC.md` or root `tasks/plan.md`. Destroys history.
- Editing a superseded decision instead of superseding it. The record of *why* is the asset.
- Asking "who is the user?"
- Success criteria with no baseline number, or no margin ("improve the score").
- Writing `derived` as `measured`.
- Writing the plan in the spec.
- Deleting a `DEFERRED` lever because it looks like a leftover. Deferred is sequenced, not abandoned.
