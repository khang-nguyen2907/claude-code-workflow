---
description: Turn a spec's levers into ordered, gated tasks — one isolated change per judged run, each with a pre-registered Accept/Verify rule and a [CPU] or [GPU, ask-first] tag.
argument-hint: "[spec layer or generation]"
---

Invoke the `planning-and-task-breakdown` skill.

Read the signed-off spec layer first — its lever registry (§9) is the task list's source.

Output paths are in `.claude/references/project-profile.md` → *Spec and task files*. **Never write to a
path that file lists under "Never write to"** — those are archived documents. A direction change
adds a dated `⟐ CURRENT PLAN (<date>)` top-block and keeps the old order below it as record.

One task = one lever or one probe. Split every lever into `<id>.1 [CPU]` (build, off-by-default switch,
prove the off-path bit-identical) and `<id>.2 [GPU, ask-first]` (one judged run). Every leaf carries an
`Accept/Verify` line that **is** the pass/fail rule, decidable before the run.

Plan mode: read-only. Present the order for review and write nothing until it is approved.
