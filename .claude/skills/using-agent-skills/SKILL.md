---
name: using-agent-skills
description: Routing and core operating behaviors for this research workspace — which skill fits the task, and the standing rules (surface assumptions, stop when confused, push back, scope discipline, verify). Use when starting a task and unsure which skill applies.
---

# Routing, and how to operate here

This is a **research workspace**, not a product codebase. The work is hypothesis → experiment →
measurement → decision.

## Which skill

| Situation | Skill |
|---|---|
| Starting a session · "where are we" · "catch me up" | read the active `tasks/todo-<gen>.md` directly |
| A new question, a direction change, a reframed target, or specifying an investigation | `spec-driven-development` |
| A signed-off spec layer needs an actionable order | `planning-and-task-breakdown` |
| Build the next task · deliver a GPU run · record returned numbers | `incremental-implementation` |
| Writing the fixtures and tests for a change | `test-driven-development` |
| A claim needs published backing, or "has the field answered this?" | `literature-review-consensus`, or the Consensus paper search |
| Read one paper for recall | `overview-paper` |
| Audit a paper's methods, gaps and hidden assumptions | `research-paper-auditor` |
| Turn a paper's Methods into something implementable | `paper-to-code-spec` |
| Wrapping up a session that holds a decision, a reversal, or a finding | `handoff` |

Old habits still resolve: "TDD" → `test-driven-development` (now pre-flight verification, not
test-first) · "the spec skill" → `spec-driven-development` (now spec *layering*) · "incremental" →
`incremental-implementation` (now the judged-run engine).

## The agents, and who runs what

All four are separate workers with their own context. They start **blind** — each delegation must carry
the task id, the subproject, the diff range, and (for `biology-reviewer`) the one-sentence biological
claim.

| Agent | Model | Use it for | Can it edit? |
|---|---|---|---|
| `biology-reviewer` | **opus**, high effort | does the code represent the biology it claims | no |
| `code-reviewer` | **opus**, high effort | correctness, ported maths, attributability | no |
| `scope-reviewer` | sonnet | is the work in the plan, one change, `Accept/Verify` met | no |
| `verifier` | sonnet | establish a fact by running a bounded CPU check | no |

Seniors review, juniors build: the two reviewers doing real judgement are Opus whoever wrote the code,
so a Sonnet implementation session still gets a senior read.

`review-team` runs the first three in parallel and triages. `/build` runs it automatically before a
commit and before a GPU handover — **standing authorization, no asking.**

The **`master`** agent is the session role for tracking the project, judging results and deciding with
the researcher. Start a whole session as it with `claude --agent master`, or take the role mid-session
with `/master`. A master session delegates **execution** to `verifier` (Sonnet) rather than running it
itself — cheaper, and it keeps the master's context for judgement. **Review** is not execution and is
not economised: it goes to the Opus reviewers.

## In this repo, specifically

- **Decision records are `docs/handoff/` plus the spec's lever registry.** There is no ADR directory.
- **`CLAUDE.md` edits belong to `handoff` Step 5 only**, as a *pointer*, never prose. No other skill
  edits a `CLAUDE.md`.
- **Ported code carries a `file:line` citation** and every deliberate deviation is flagged as a
  decision.
- **Skills about browsers, UI, deploys, HTTP surfaces and CI cannot fire usefully here.** If one seems
  to apply, re-read the task.

## Core operating behaviors

**1. Surface assumptions before acting.**

```
ASSUMPTIONS I'M MAKING:
1. ...
→ Correct me now or I'll proceed with these.
```

**2. Stop when confused. Do not guess.** Name what is unclear and ask. In this repo a guess costs GPU
hours: a next-steps menu that skipped two ordered tasks led to a ≈6-hour run whose verdict was
**void**.

**3. Push back.** If a simpler approach exists, or the evidence does not support the plan, say so. If a
prior conclusion of yours was wrong, reverse it in writing and name it — reversals are the most
valuable thing the handoffs preserve.

**4. Scope discipline.** Touch only what the task requires.

```
NOTICED BUT NOT TOUCHING:
- ...
```

A suggestion that is not in the spec or plan is labelled **"NOT A PLAN TASK — unapproved proposal"**,
offered in chat, and **never written into the plan as a task.**

**4b. Scope, and other sessions editing at the same time.** Several sessions can edit this repo at
once. Never revert, stage or tidy an uncommitted change you did not make — it is probably another
session's live work; if a file already shows modified and you did not modify it, say so and ask. When
the task is the tooling (`.claude/`), the research project is read-only evidence: read it to ground a
decision, never edit `src/`, `tests/`, `configs/`, `tasks/`, `SPEC*.md` or any `CLAUDE.md` while doing
config work.

**5. Report state honestly.** Distinguish: exists as code and ran on a server · tested on CPU only,
never run on a GPU · **not built**. *"Claiming work is done when it was only designed"* is the named
failure mode. `BUILT, NOT RUN` is a complete and honest status.

**6. Ask first** before: real model weights, real training data, GPU time, a new dependency, or an
on-disk format change. Spent and rejected approvals are on record in the project `CLAUDE.md` — do not
re-litigate a rejected one without new grounds.

**7. Explain, don't just be accurate.** Every technical claim: **job → evidence → consequence**.
Technical terms are fine; unexplained terms and maths-only explanations are not. No metaphors. Numbers
come with their baseline and noise. Bug explanations have a fixed order — behaviour first, maths last.

**8. Ground every claim, and grade it.** Grades: `measured` · `derived` · `literature` (with its
dataset, split and metric) · `assumption` · `open`. The default is not "true"; architecture intuition
is not evidence. Check the literature before an expensive run. A paper's number is not a baseline
until its conditions match. Depth, source ranking and anti-patterns:
`.claude/references/evidence-standards.md`. The `master` role carries this as a standing mindset —
`.claude/agents/master.md` → *Claims carry their evidence*.

**9. Build only when asked.** Default mode is discussion; `/build` runs on explicit request (it
carries `disable-model-invocation: true`), not because a message sounds like a task. Most messages
are questions or thinking out loud — answer them, and if code seems like the answer, say what you
would change and ask, rather than building.

Report order after a build; see `incremental-implementation` → *Closing report*.
