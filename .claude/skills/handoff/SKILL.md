---
name: handoff
description: Wrap up a session into a dated log under docs/handoff/ with two jobs: a "Resume here" block a brand-new chat can act on, and the record of how the conclusion was reached (lessons, reversals, rejected options, evidence). Then, only if navigation went stale, adjust the relevant CLAUDE.md pointer. Use on "wrap up", "we're done", "log this", "record this discussion", "handoff", "end of session", "lesson learned", or when a long discussion is about to be compacted.
argument-hint: "[optional topic slug]"
allowed-tools: Read Write Edit Bash Glob Grep
---

# Handoff

One file, two jobs, in this order:
1. **Resume here (forward).** A new chat with zero context can act on it: where things stand, next step, minimum files to read, commands to verify state, what not to touch.
2. **The record (backward).** How the conclusion was reached: lessons, reversals, rejected options and why, evidence. Code shows what was built and git shows when; only this shows what was *rejected and why*.

**CLAUDE.md is neither.** It is a navigator (where to look), loaded every session, so every line costs context forever. Never dump handoff content into it; at most correct a pointer this session made stale. The *why* stays in the handoff.

## Required: three artifacts, or the handoff is incomplete (do not report it done)

1. **Folder:** `<project>/docs/handoff/` of the project the work touched. Create it, with its `README.md` index, if missing. Never write to a project root, to `docs/` directly, or to one shared location.
2. **Dated file:** `docs/handoff/YYYY-MM-DD-topic-slug.md`.
3. **Index line:** appended to *that folder's* `README.md`, newest first. Mandatory every time; an unindexed handoff is lost.

Reference example: `archive/pocketscope_src/docs/handoff/2026-09-02-esm3-sequence-front-end.md`. Section skeleton: [`handoff-template.md`](handoff-template.md).

## Step 0: does this conversation deserve one?

Write one if **any** is true (an empty diff is fine; understanding counts):
- A generalizable **lesson** was learned (method that worked, trap found, working agreement settled, intuition proved wrong).
- A **decision** constrains future work (approach chosen, option rejected).
- The user **changed their mind** or a plan was abandoned (the reasoning for a reversal is the most valuable thing to keep).
- **Non-obvious evidence** appeared (a measurement contradicted an assumption, a dependency imposed a constraint).
- A **spec, plan or investigation** was designed.
- Work was **left incomplete**, or a run was **delivered but not judged**.
- The next step happens **in a new chat**.
- A **discussion was cut off mid-way** (context ran out or interrupted). Most often lost, since nothing was decided yet.

Skip, and say so in one line, for: a Q&A, a bug whose diff explains itself, routine refactor/formatting, or anything git diff plus existing docs already explain.
Explicit `/handoff`: write one even if marginal. Triggered by a nudge or your own judgment: apply the bar and decline out loud.

## Step 1: establish what happened (before writing)

Describe the session as it occurred, not as it would read best.

```bash
git status --short && git log --oneline -8 && git diff --stat HEAD
```

Reconstruct from the conversation:
- What the user asked, in their words (quote the framing request).
- Options put to them and which they picked, **including those they didn't**.
- Where they pushed back, corrected you, or reversed.
- What reading code/docs/dependencies taught you that changed direction.
- What is unfinished, unmeasured, delivered-not-run, or awaiting approval.
- If a discussion was cut off, reconstruct the **thread**, not just the topic: what prompted it, options on the table, which way it leaned and why, what was dismissed and why, the unanswered objection, what would settle it. Otherwise the next session re-derives the argument and re-raises dropped points.
- What you would do differently next time, and the evidence.

**Never invent a rationale.** If no reason was given, write "no reason recorded."

## Step 2: pick the destination

Route by where the work landed (`git status`). Subprojects and which are active: `.claude/references/project-profile.md` -> *Layout*.

| Work touched | Handoff goes to | Navigator to check |
|---|---|---|
| exactly one subproject | `<subproject>/docs/handoff/` | that subproject's `CLAUDE.md` (or `README.md`) |
| several subprojects, or the workspace itself (incl. `.claude/`) | repo root `docs/handoff/` | root navigator |
| single-package repo | `docs/handoff/` | `CLAUDE.md` |

Work in a stopped/archived subproject is logged in its own `docs/handoff/`; leave the root navigator alone.

Create the directory (`mkdir -p <project>/docs/handoff`) and `README.md` if missing, copying the format from an existing folder's `README.md`; for a new folder write the header plus an empty `## Index` first.

Filename: date from `date +%F`, slug from the subject (not the branch). If it exists, this is a second discussion: use `-2` and link back. **Never overwrite.**

## Step 3: write it

Fill [`handoff-template.md`](handoff-template.md). Drop any section with nothing real to say.

- **Unfinished discussion goes in `Open threads`** (forward half). It is the only section not reconstructable from the repo, so when room is short write it **first**.
- **Forward half is written for a stranger:** repo-relative or absolute paths, copy-pasteable commands with expected output, no pronouns referring to this conversation. **Minimum reading list:** the active spec's top layer only (not superseded layers), the todo, this handoff, and the few key code files, most important first. Extra files cost the next session's context.
- **Backward half is written for the record:** past tense, specific, cited. "ESM3's `logits()` is wrapped in `torch.no_grad()` ([esm3.py:519](path))", not "there were gradient issues."
- **Lessons learned:** generalizable and backed by evidence from this session; each names what it would change next time. No evidence means cut it. If a lesson is a failure that looks like success, flag it as a trap candidate for Step 5.
- **Written once, never revised.** `Resume here` is a snapshot: the **newest** index entry is the live one, older blocks stay stale on purpose. A later session that overturns this one writes its own and references this one.

## Step 4: update the index (mandatory gate)

Sessions chain, so a new session needs the *end of a chain*, not the newest file. Unlike handoffs, the index **is** maintained.

```markdown
# Handoff notes: <scope>

## Open threads
<!-- Unfinished arguments / undecided branches. Maintained: delete or mark settled when closed. -->
- **<the open question>**: latest: [YYYY-MM-DD](file.md) | started: [YYYY-MM-DD](file.md)
  - **Blocked on:** <a measurement | the researcher's decision | a run in flight>

## Index
<!-- Chronological, newest first. Written once per handoff, then left alone. -->
- [YYYY-MM-DD: <what was settled, one-line abstract>](file.md) (branch `name`)
  - **Continues:** [YYYY-MM-DD](earlier-file.md) or "new thread"
  - **Decided:** <decision constraining later work, and what was rejected>
  - **Measured:** <numbers and what they establish> or "no code, no numbers"
  - **Reversed:** <what stopped being true, if anything>
  - **Open thread left:** <unfinished argument, mirrored in Open threads above>
  - **Do not re-run / do not reopen:** <anything this entry protects>
```

- `Open threads` is what a new session reads first. When a thread settles, delete its bullet or move it under `## Settled` with the closing handoff.
- `Continues:` links backward only (knowable at write time); the forward view lives in `Open threads`.
- Entry rules: at most one line per sub-field; drop empty sub-fields; write for a searcher (lever or task id, metric name, component, decision); the title says what was **settled**, not what was worked on; numbers carry their conditions.
- New folder: create `README.md` in this shape. **Do not retrofit older entries**; just add `Open threads` at the top.

**Verify:** the file exists at the routed path, `grep` finds its filename in the index, and any unfinished argument appears in `Open threads`. Otherwise Step 4 is not done.

## Step 5: check the navigator (default: no change)

Default outcome: "no CLAUDE.md change needed." Edit only for these, as a **pointer**, not prose, and keep edits surgical:
- **Stale status pointer:** amend the existing line; don't explain how it moved.
- **New signpost:** one line, what + path.
- **Approved ask-first item** (dependency or format change), so nobody re-litigates it.
- **Trap** (failure that looks like success, must be known before acting): one terse line + path to the handoff for the why.

Test: does a future session need this line to know *where to look*, or is it the *answer* (belongs in the handoff; link, don't copy)?

## Step 6: report

A few lines: which file; confirmation the folder's `README.md` now lists it; whether the navigator changed (which line, or "no CLAUDE.md change needed"); anything deliberately left out. **Do not commit or push the handoff.** Documents are the researcher's to commit (code differs: see `incremental-implementation` Mode C). No `git push` of documents without explicit confirmation.

## Never

- A `Resume here` a newcomer cannot act on (test it by reading it cold).
- A reading list of "everything relevant," or one naming a superseded spec layer.
- Writing one for a session that didn't earn it (Step 0).
- Inventing reasoning; use "no reason recorded."
- Platitude lessons. "Test more carefully" is not a lesson; "a diagnostic that rebuilds the model input by hand silently ignores a config flag, so assert against the real forward" is.
- Sanitizing: record neutrally when the user rejected your recommendation, corrected you, or you were wrong in a way that changed direction.
- Treating CLAUDE.md as a second log.
- Overwriting a handoff (use `-2`).
- Writing the handoff but not indexing it.
- Filing it in the wrong project (route by `git status`).
- Skipping it because `docs/handoff/` doesn't exist (create it).
- Claiming work is done when it was only designed or delivered-not-run. State what exists as code, what ran on a server, and what exists only on paper.
