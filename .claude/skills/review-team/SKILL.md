---
name: review-team
description: Dispatch the reviewers a task assigns on its `Review:` line (code, biology, scope) in one message, then merge their findings into one verdict. Use from a build's review step; the policy for when and how often lives there.
allowed-tools: Read Grep Glob Bash Agent SendMessage
---

# Review team

This file covers only *how to dispatch and merge*. When to review, how many rounds, and what to do with findings are set by `incremental-implementation` -> Mode C step 5.

## Who runs

The task's `Review:` line decides: `code` | `biology` | `scope` | `none`.
- No line: run `code` and say the plan did not specify.
- Reviewer named but not installed: skip it and say so. Never substitute another.
- `scope` is normally **not** dispatched (the builder already holds the plan and checks inline). Use the agent only when the reviewer is not the builder (an audit, or a commit from elsewhere).

## Dispatch

Reviewers start blind (no conversation, no `CLAUDE.md`). Send all in **one message** so they run concurrently.

```
code-reviewer     task <id> | <subproject> | diff <range> | risk areas: <lines to look at>
                  | gate: <pass/fail + counts from the build's own gate run>
                  | axes: <optional, e.g. 1,4>
biology-reviewer  task <id> | <subproject> | diff <range> | claim: "<one sentence>"
                  | risk areas: <lines that encode the claim>
                  | checks: <optional, e.g. 2,5>
```

## Writing the delegation message

A reviewer's job is to find what the builder's own pass could not see (conflict, bug, wrong-logic path, edge case), not to repeat the builder's work. Hand over everything already known.

- **Scope as a fact:** `task <id> | <subproject> | diff <range>` with a real commit range, never "the recent changes."
- **Risk as a claim to check, not a file to read.** Not "review `chain_fusion.py`" but "check whether the mask at `chain_fusion.py:142` still excludes padding after this change."
- **Pass the gate result** (pass/fail + counts from Mode C step 4) to `code-reviewer`, so it never re-runs `pytest`/`ruff`/`mypy`.
- **Hand over other known facts:** which tests already cover which claim, where the relevant data sample lives. Re-stating for independent verification is fine; making the reviewer re-find it is wasted turns.
- **State negative scope:** don't re-run the gate, don't explore past the diff unless something specific forces it.
- **Ask for defects only.** No praise, no non-defect suggestions. Every finding comes with a specific fix (`code`) or what it means for the result (`biology`).
- **Narrow the checks.** Most diffs touch 2-3 of the biology checks or code axes. Name them (`checks:` / `axes:`) so the reviewer skips the rest and lists them as not applicable.
- **Large diff:** write it to a scratch file (`git diff <range> > <scratch>/review.diff`) and pass the path instead of pasting it.
- **Precise, not short.** Exact `file:line` and exact claim. Terse "review this" gives shallow, generic findings.
- **`biology` requires the biological claim in one sentence.** If you cannot state it, stop and ask the researcher. Never invent one.

## Merging

Report one verdict, not three reports.

- **Deduplicate.** E.g. "the diff changes two things" and "off-path not bit-identical" are usually one defect: report once, with both views.
- **Resolve disagreement by evidence, not majority.** A reviewer citing a `file:line` and a real value beats one reasoning from shape. Say which you took and why.
- **`CANNOT TELL` is not a pass.** Report what could not be checked and what would check it.
- **Keep their grades:** a reviewer's `derived` claim stays `derived`.
- **Turn cap hit:** say so and say what was not reached. Do not respawn the reviewer (that repays the whole review); continue it with `SendMessage`: "write your report now from what you checked; mark the rest `open`."
- **Carry each reviewer's suggested fix through,** not just the finding. The written report must be actionable on its own, since it is what a later todo entry gets written from.

```markdown
### Review: <task id>
**Code:** APPROVE | REQUEST CHANGES   **Biology:** REPRESENTS THE CLAIM | DOES NOT | CANNOT TELL

**Blocking:** <finding, file:line, which reviewer, suggested fix>
**Worth knowing:** <finding, and suggested fix if given>
**Unchecked:** <what no reviewer verified, and what would verify it>
```

**If the commit happened before the review ran,** record a `DEVIATION`. Do not write "already pushed; nothing warranted holding it back" (that judges the process by one outcome).
