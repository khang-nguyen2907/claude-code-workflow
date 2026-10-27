# Handoff template

Two halves. **Resume here** comes first because a new chat reads top-down and needs to act before it
needs the history. Drop any section with nothing real to say.

---

# <What this session settled, in one line>

**Date:** YYYY-MM-DD · **Branch:** `name` · **Base commit:** `abc1234`
**Participants:** researcher, Claude (<model>)
**Outcome:** one sentence — what is true now that wasn't before.
**Produced:** links to every document, script, config or run-guide this session created.

---

## Resume here

*For a new chat with no context. Everything below this heading must work without the conversation.*

**Where this left off.** One short paragraph: the state of the world. Name what is built, what ran on
a server, what is `delivered — NOT RUN`, and what is only on paper. Built is not run.

**Next step.** The single concrete thing to do, with its task id from the plan.
If the next move is a decision rather than work, say so: *"the researcher reads the table and
chooses — do not build the next lever."*

**Minimum reading list** — smallest set, most important first. Be strict.

1. `<subproject>/tasks/todo-<gen>.md` — the live state; **read before assuming any component's state**
2. `<the ACTIVE top spec layer only>` — not the superseded layers below it
3. this handoff
4. `<the one or two code files the next step touches>`

**Verify before you start** — copy-pasteable, with the expected output.

```bash
cd <subproject>
git log -1 --oneline                  # expect: <commit subject>
<the project's data-integrity check>                  # expect: data matches the committed manifest
<the project's gate>                  # expect: N passed
```

For a job in flight: <the project's queue-status command>; logs at `<path>`.

**Do not touch / do not re-run.**
- `done-negative` results — name them: *"do not re-run init/K sweeps or the 1-GPU check."*
- Locked decisions and rejected ask-first items, so they are not re-litigated.
- Anything whose branch is the researcher's call.

**Stale docs this session created.** What is now wrong, and what is authoritative instead.
e.g. *"`SPEC-training-perf` P9–P12 still says 'LoRA both routes'; the code is the hybrid —
trust `el_dev_slice_hybrid.yaml` and the 2026-09-23 handoff."*

**Ripple effects.** What this session changed about *future* tasks — a threshold that must now be
recalibrated, a later lever that just became moot or newly necessary, a plan step whose order changed.

**Open threads — a discussion cut off mid-way.** The hardest thing to carry across a session, and the
thing a task list cannot hold. For each unfinished discussion, enough that the next session can *argue
on* rather than *start over*:

```markdown
### Thread: <the question being discussed>
- **Where it started:** <what prompted it>
- **Options on the table:** <each one, in one line>
- **Leaning toward:** <which, and the reason — or "no lean yet">
- **Already dismissed:** <option, and why — so it is not re-raised>
- **Unanswered objection:** <the thing that was blocking agreement>
- **What would settle it:** <the measurement, the file to read, or the decision that is the
  researcher's>
```

Write this **before** the sections below if room is short. A settled decision can be reconstructed from
the todo and the code; a half-built argument cannot be reconstructed from anything.

**Prompt for the next session** — copy-paste, not saved anywhere else.

```
Read <path-to-this-handoff> first, then <subproject>/tasks/todo-<gen>.md.
Task: <id> — <one line>.
Constraints: <the two or three that matter>.
Do not <the thing that would waste a run>.
```

---

## The record

### The ask
The user's framing request, quoted.

### Starting state
What was true before — especially anything that later constrained a decision, or that
already-finished work would have been discarded by.

### Decisions

| Question | Chosen | Rejected |
|---|---|---|
| | | |

Then prose for the two or three whose *reasoning* matters more than their outcome.

### Reversals
Where the direction changed. Give the original position its honest case **before** the argument
against it. If the user corrected you, record it plainly — neither defensively nor apologetically.

### Findings
Evidence from reading code, docs, papers or measurements. Each **graded** — `measured` / `derived` /
`literature` / `assumption` / `open` — with a `file:line` citation for code, or the citation plus the
dataset, split and metric for a published number. Note what each finding changed.
Rules: `.claude/references/evidence-standards.md`.

### Lessons learned
Generalizable, evidence-backed, and each naming what it changes next time. Mark the type:

- **Method** — a way of working that proved out, and why it worked.
- **Trap** — a failure that looks like success. Flag as a Step-5 CLAUDE.md candidate.
- **Wrong intuition** — what was believed, what corrected it, what the tell was.
- **Working agreement** — a rule the researcher stated, quoted.

*A lesson with no evidence behind it is not a lesson — cut it.*

### Anything added that the user didn't ask for
Flag it as such, with why.

### Open items
Distinguish: **unmeasured** · **delivered, not run** · **ask-first, unapproved** · **blocked** ·
**deferred** (sequenced later, not abandoned) · **never answered** (a question put to the researcher
that got no reply — say so rather than deciding for them).

State plainly whether anything is committed.
