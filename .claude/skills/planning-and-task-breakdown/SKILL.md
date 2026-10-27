---
name: planning-and-task-breakdown
description: Turn a spec's lever registry into ordered, gated tasks — one isolated change per judged run, each with a pre-registered Accept/Verify rule and a [CPU] or [GPU, ask-first] tag. Use when a spec layer is signed off and needs an actionable order, or when a direction change needs re-sequencing. Plan mode: read-only until approved.
allowed-tools: Read Write Edit Bash Glob Grep
---

# Plan the levers

A plan here orders **experiments**, not features. Each task is one lever from the spec's §9 registry
(or one probe), sliced so that its result is attributable to exactly one change.

## Step 0 — plan mode, read-only

Write nothing until the order is approved. The output of planning is a plan, not code.

## Step 1 — output paths

The paths, and whether this project names task files by generation, are in
`.claude/references/project-profile.md` → *Spec and task files*. Read them there.

The rule that holds everywhere: **never write to a path the profile lists under "Never write to"** —
those are archived documents that a plausible-looking default path would overwrite.

**A direction change moves the old record out, it does not bury it below the new one.** Write the new
order as the document's own structure, and move the superseded plan and todo to the
archive location in the profile (*Spec and task files* → *Superseded task records*), with a one-line
pointer from the new file. Most projects already have such a folder; use it rather than inventing a
second convention.

**Do not keep the superseded order in the same file.** Measured on a real case: half a 606-line todo
was a dead plan at flat `##` headings while the live work sat inside a `>` blockquote at indent depth
4–6, holding 4 of the file's 46 checkboxes. The dead plan read like the document and the live plan read
like an aside.

## Step 2 — the header every plan carries

1. The **target**, as a number against a baseline, copied from the spec — plus which signal is
   **demoted to secondary** and why.
2. The **`[CPU-trivial]` / `[CPU]` / `[GPU, ask-first]` legend.**
3. The **standing gate**: `uv run pytest tests/unit tests/smoke -q` + scoped `ruff` + `mypy` at the
   recorded baseline count, before any task is considered done.
4. The **GPU task delivery contract** (root `CLAUDE.md`): script + run-guide + pass/fail rule, together,
   every time. *"Each task's `Accept/Verify` line **is** that rule — restate it in the handover, never
   leave the researcher without it."*
5. A **dependency graph** as ASCII, with the gates drawn in.
6. **Done so far — carried in as baseline (do NOT re-run)** — carrying forward every `done-negative`
   result so it is never paid for twice.

## Step 3 — slice by lever, and split every lever in two

One task = one lever, or one probe. **Not** one user-visible path.

Split each lever so that `/build`'s dispatch is unambiguous and the build is reviewable before it
costs GPU time:

```
<id>.1  [CPU]             build it behind an off-by-default switch; prove the off-path
                          bit-identical; unit + smoke
<id>.2  [GPU, ask-first]  one fresh judged run of that switch, and nothing else
```

**One change per judged run.** Bundling is the named anti-pattern — the `gen2 _deep` run changed four
things at once and its verdict is **void, not negative**. If two changes must ship together, say in the
task why the result will still be attributable.

## Step 3a — `[CPU-trivial]` versus `[CPU]`

Not every task is a lever. A config value, a CLI flag rename, a comment or docs edit inside `src/`, or
wiring a script to an already-reviewed entry point has no numeric or behavioural effect on any result
— tag it `[CPU-trivial]` rather than `[CPU]`. `/build`'s Mode T skips the off-path bit-identical
fixture, the four-test-pattern requirement, and the default reviewer dispatch for that tag — they
check nothing a config rename could break, and spending them anyway is why trivial tasks were taking
as long as real ones.

**The test is effect, not size.** A one-line change to a loss weight or an indexing offset is `[CPU]`
even though the diff is tiny, because it changes a measured number. A sprawling but mechanical rename
across twenty call sites is still `[CPU-trivial]` if none of them touch model, loss, optimizer,
data-pipeline, or metric-definition code. When genuinely unsure, tag `[CPU]` — the cost of
over-tagging is a few extra minutes of review; the cost of under-tagging is a numeric change that
shipped with no fixture and no reviewer.

## Step 2b — the orientation block: make the plan envisionable

A reader who knows the project must be able to open `todo-<gen>.md` and, in the **first 40 lines**, see
what the work is for, how it flows, and what to do next. If they have to reconstruct that from a task
list, the plan has failed — this was reported directly: *"even I read them, I cannot envision which
actions or jobs should be implemented, the pipeline, the workflow, the logic connected to project
targets, phase target."*

Put these three things at the top, in this order, as the document's own structure — not in a blockquote.

**1. The target chain.** Three lines, each a number or a decidable claim:

```markdown
**Project target:** <the deliverable, with its metric and baseline>
**This phase:** <what this phase alone must establish, and how we will know>
**Why these tasks:** <one sentence connecting the task list to the phase target>
```

**2. The pipeline.** An ASCII diagram of the **current track only**, showing order, what gates what,
and where a decision point sits. Not the superseded track. Mark `[CPU]` and `[GPU]` so cost is visible
at a glance, and mark the decision points — a reader should see where they will have to choose.

```
P0 [CPU] boundaries ──▶ B-trim [CPU build] ──▶ B-trim [GPU] ──┐
                                                              ▼
                                                    ◆ decision: D_w moved?
                                                     ├─ yes ─▶ re-add one-hot
                                                     └─ no  ─▶ G9 / objective
```

**3. Next actions.** A table of the next **three at most**, so the immediate move is unambiguous:

| id | tag | what | why now | gates |
|---|---|---|---|---|
| B-trim.1 | `[CPU]` | trim + delete pooling | pooling is the measured bottleneck | B-trim.2 |

Then the task list. Everything below the orientation block is detail; the block alone must be enough
to know what to do next.

**Keep it short and stable.** The orientation block is rewritten when the direction changes, not when a
task finishes — task state lives in the checkboxes and `RESULT` blocks. If it grows past ~40 lines it
has started duplicating the task list.

## Step 3b — cheapest evidence first, and that includes the literature

Before any `[GPU, ask-first]` task is written into the plan, ask: **has this already been answered?**
A literature check costs minutes; a GPU arm costs hours on a machine other people are waiting for.

- If a paper answers it, the task becomes a citation in the spec, not an experiment.
- If a paper answers it *under different conditions*, the task stays — but the plan records what
  differs (dataset, split, metric) so the result can be compared honestly.
- If the field tried it and dropped it, record that as the reason and decide deliberately whether to
  re-test it.

This is the existing *"cheap → expensive; each tier earns the next"* rule applied to external evidence.
Order within a phase: literature → CPU diagnostic → short GPU arm → full run.
See [`../../references/evidence-standards.md`](../../references/evidence-standards.md).

## Step 4 — the task shape

```markdown
- **<id>.<n> [CPU-trivial | CPU | GPU, ask-first]** <what changes, in one sentence — the config/byte-diff if there is one>
  - **Accept/Verify:** <the pass/fail rule, as a decidable check>
  - **Review:** <code | biology | scope | none, comma-separated>
```

**`Review:` is yours to assign, per task.** You know what the task touches; the building session does
not get to guess, and no fixed rule would transfer to another project. Assign by what could go wrong:

| Assign | When |
|---|---|
| `code` | almost always — correctness, ported maths, attributability |
| `biology` | the change touches how the domain is represented: residue slicing, chain handling, masking, label or group semantics, a loss that encodes a domain claim. **Not** for config-only, test-only or wiring changes. |
| `scope` | the reviewing session will not be the one that built it (an audit, a review of a commit from elsewhere) |
| `none` | a pure docs or comment change, or any `[CPU-trivial]` task — say why in the task. |

Reviewers cost real money per run — `biology` and `code` are Opus at high effort. Assigning `biology`
to a config-flag task spends that for nothing; omitting it on a residue-slicing task is how a
plausible wrong number reaches a spec. Decide deliberately, task by task.

If the project's spec declares no biology dimension (see `spec-driven-development` → *Review policy*),
do not assign `biology`.

Rules for `Accept/Verify`:

- A `[CPU]` task's rule is a **test or a property**: "`input_norm: true` gives `ab` rows of ~√d_model
  whatever the input scale, and `false` is bit-identical to the current forward (regression fixture)."
- A `[GPU]` task's rule is a **number, a threshold, and the branch each outcome routes to** — fixed
  now, before the numbers exist.
- A task whose rule cannot be stated is not ready to be a task. Say so instead of writing a vague one.

## Step 5 — gates, risks, and the stop rule

- **Phase Checkpoints**, written with a live status: `Checkpoint A (root fixed) — OPEN`. *"Until it
  holds, Phase C is not judged."*
- A **Risks** section naming the ways this plan fails, including its own temptations: *"Stacking tempts
  bundling — one-change-per-judged-run is the guardrail."*
- The **routing table** from the spec, restated where the branch is taken, with thresholds.

## Step 6 — two guardrails that exist because they were broken

Both are recorded DEVIATIONs in `todo-gen3.md`. They are the most expensive failures in this repo's
history, and neither was a coding error.

**(a) A task is buildable only if it has a plan id.** Anything else is offered in chat labelled
**"NOT A PLAN TASK — unapproved proposal"** and is *never written into plan or todo as a task*. An
unapproved allele screen was built and wrongly entered the plan this way; it had to be reverted.

**(b) A "what next?" menu must list every unchecked task the plan orders *before* the candidate**,
with the cost of skipping each. A menu that omitted C.1 and G4 led to G5 being run at an untuned LR —
≈6 GPU hours, and the result **void for depth**.

## Step 7 — present, don't write

Present the order for review. On approval, write the plan and the todo. The todo is where results
are recorded:
tasks start as `- [ ]` and grow a `RESULT` block when judged — see the `incremental-implementation`
skill for that block.

## Failure modes

- Slicing by user story or by layer instead of by lever.
- An `Accept/Verify` line that is not decidable ("works correctly", "performance improves").
- Gating on "tests pass" for a `[GPU]` task — tests are the pre-flight, never the verdict.
- Writing a proposal into the plan as a task.
- Offering a next step that skips an earlier ordered task without saying so.
- Dropping a `DEFERRED` lever from the plan because it is not current.
- Re-running something already recorded `done-negative`.
