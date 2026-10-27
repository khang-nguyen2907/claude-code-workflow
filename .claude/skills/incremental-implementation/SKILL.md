---
name: incremental-implementation
description: Build the next task in a research plan. Either a local CPU task, or a GPU handover (script + run-guide + pre-registered pass/fail). Use when implementing a planned task or handing over a GPU job. Enforces one change per judged run and stops where the decision is the researcher's.
allowed-tools: Read Write Edit Bash Glob Grep
disable-model-invocation: true
---

# Build a judged run

Results are judged from GPU-server numbers you cannot reach. Picking the wrong mode is the most common mistake, so pick first.

## 1. Pick the mode

Read the active `tasks/todo-<gen>.md`. Take the first unchecked task with no sub-tasks — if it has `[CPU]`/`[GPU]` children, open it and repeat until you reach one with none. Match top to bottom:

| This turn... | Action |
|---|---|
| names a mode: `/build <task-id>` or `/build deliver` | that mode |
| brings numbers from a finished run (result, log, job id, done/failed/OOM) | **STOP.** Not yours to judge. Tell the researcher to paste it to the master. |
| next task is `[CPU-trivial]` | [mode-t.md](mode-t.md) |
| next task is `[CPU]` | [mode-c.md](mode-c.md) |
| next task is `[CPU build -> GPU]` | [mode-c.md](mode-c.md), build half only. GPU half is a separate turn. |
| next task is `[GPU...]`, no run-guide yet | [mode-g.md](mode-g.md) |
| next task is `[GPU...]`, run-guide sent, no result | **STOP.** Say "delivered, waiting on numbers." |
| needs something from the researcher first | **STOP.** Say what is needed. |
| no tag, 2+ candidate tasks, last result's branch not chosen, or approval not on record | **STOP. Ask one question.** (This exact gap caused this project's two recorded `DEVIATION`s.) |

State the mode in one line before doing anything. Open only the one mode file you need.

## 2. Work cycle (per slice)

Implement the smallest complete piece -> test -> review -> fix -> commit -> next slice.

- **Test:** run the suite, or write one if none exists.
- **Review:** run the task's `Review:`-tagged reviewers (code / biology / scope), real problems only.
- **Fix** what they find yourself:
  - Critical: fix, then the same reviewer rechecks **once**. Still Critical: stop and ask the researcher (mode-c.md step 5). No second full review round.
  - Important and easy: fix now.
  - Important but hard: log it in the todo with an id.
- **Commit** with a clear message, only after review and the build gate (tests + lint + types) pass.

## 3. Slicing

- **Vertical slices (default).** Each slice is one complete, testable path through the lever (one isolated experimental change). Example: (1) new op + shape/gradient check, (2) wired into forward pass behind the off switch, (3) on-path tests (mode-c.md step 3), (4) full lever on smoke config. Never leave a half-built mechanism with no test.
- **Contract-first.** If a lever splits into pieces that only share an interface, write the interface first (shapes, dtypes, mask rule, label format), build each side against it independently (optionally via `Agent`, see `dispatching-parallel-agents`), then join and run on-path tests and the gate. Still one lever, one gate run, one todo entry.

## 4. Rules

- **One change per judged run.** Never bundle two changes.
- **Simplicity.** Write the plainest correct version for the lever in front of you — e.g. the one fusion operation it needs, not a config-driven operator registry. No base classes or builders for a future lever. Three similar lines beat a premature abstraction. Optimize only after a test proves correctness.
- **Scope.** Touch only what the task needs: no cleanup, no unrelated imports, no deleting comments you don't understand. Report anything else as:
  `NOTICED BUT NOT TOUCHING: <file> has <issue> -> want a task?`
- **Separate commits** for a deletion and its replacement.
- **Safe default.** The new switch defaults to old behaviour, backed by the off-path bit-identical proof (mode-c.md steps 1-2).
- **Not applicable:** rollout feature flags, DB migrations.

## 5. Closing report (every mode, fixed order)

1. **Main question** this task was meant to answer.
2. **Answer** in 1-2 sentences, first: "Yes: ..." / "No: ..." / "Partly: ..." If unknown, say what is missing.
3. **Plainly explained:** diagram or flow first (real paths, variables, shapes), how to read it, what each term means in this project and what healthy vs broken looks like.
4. **What I did,** kept in three buckets: asked by the task / forced by the change (say why it was necessary) / unrelated (flag; if only noticed, leave alone). Any "missing / not wired / not done" claim must be verified by a real search. State what you checked, or label it `assumption`.
5. **What I found:** real numbers labeled `measured` / `derived` / `literature` / `assumption` / `open` (see `.claude/references/evidence-standards.md`). State plainly if a gate failed. External numbers need their split and metric.
6. **Why it matters** for the hypothesis and next step. Mechanisms must be concrete (residues, chain, region, why the measured result changes), else label `assumption`.
7. **Needed action** (required, always last). Exactly one of:
   - **Something to run:** script + guide (output location, success vs failure signs, what to paste back, pass/fail rule).
   - **Nothing to run, next step is mine:** what it is and what I'll type to start.
   - **Nothing to run, next step is theirs:** the one thing they must do.
   - **Decision only they can make:** one question plus your recommendation.

Mode-specific length:
- Mode C: sections 3 and 6 short; 5 is the gate result; 7 says what is next. `N/A - no biological claim` is a valid answer for 3 or 6.
- Mode T: 3, 4, 6 are one line each.
- Mode G: section 7 is the delivery (script, run-guide, pre-registered pass/fail table). State that nothing has run yet.

Name things specifically: real file path, real shape, and what a summary number summarizes.

## Never

- Claim something is missing without a proper search, or treat one empty guessed path as proof.
- Commit before reviewers have run, or excuse it afterward because the findings turned out minor.
- End with a to-do list you could have done yourself, or a plain summary, or skip **Needed action**.
- Call a fix forced by your own change "a pre-existing bug I also fixed."
- Mark a GPU task done before its numbers exist.
- Judge a run or tick a task from numbers someone pasted in.
- Bundle two changes in one judged run.
- Suggest a next step that skips a task the plan put ahead.
- Submit a Slurm job yourself.
- Finish a `[CPU-trivial]` change that affects a number: stop and rebuild it as `[CPU]`.
- Run a second full review round, or ship after a Critical finding survived the one allowed recheck.
