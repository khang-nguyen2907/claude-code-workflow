# Using this `.claude/` for a computational biology research project

This configuration is built for **research**, not software delivery. The unit of work is a hypothesis
tested by a measurement, not a feature shipped. Success is a number crossing a threshold that was fixed
*before* the numbers existed — not a passing test suite.

It assumes a project shaped like this. Check before adopting it:

- The work is **hypothesis → experiment → measurement → decision**, and negative results are kept.
- Expensive compute (GPU, a cluster, long jobs) is **submitted by the researcher**, not by the agent,
  and often on a shared machine.
- Claims must be grounded — own measurements, published work — and graded by their evidence.
- The code models a **biological idea**, so an operation can be numerically correct and biologically
  meaningless.

If none of that is true, use a normal software setup instead.

---

## 1. Setting up a new project

Copy `.claude/` into the new repository, then make these three edits. Nothing else needs changing.

### a. Rewrite `references/project-profile.md` — the only required edit

Every skill, command and agent reads its specifics from this one file: layout, spec and task paths,
the gate commands, compute and submission, reference numbers, ask-first list. Fill in each section,
and **delete a section that does not apply rather than leaving a stale value**.

The two fields that prevent the worst accidents:

- **"Never write to"** — list any path that holds an archived or historical document which a
  plausible default would overwrite (a stale `SPEC.md`, an old `tasks/plan.md`). `/spec` and `/plan`
  refuse to write to anything on this list.
- **The gate** — the exact test, lint and type-check commands, and the type-check **baseline count**.
  In a repo with pre-existing errors the baseline is a number, not zero.

### b. Optional: list your own domain pitfalls

Nothing domain-specific ships here. If the project has recurring mistakes that fail **silently** —
returning a plausible wrong number instead of crashing — list them in the profile's *Domain pitfalls*
field directly, or in a short file under `references/` if the list grows:

```markdown
## Domain pitfalls
- <the mistake> — <what to assert instead>
```

Nothing loads this automatically — `test-driven-development` and `biology-reviewer` already point at
*Domain pitfalls* by name, so a skill that needs it reads the field on demand rather than it being
injected into every session.

The test for an entry: **does it fail silently?** A trap that crashes does not need an entry. A trap that
returns a believable wrong number does. `skills/test-driven-development/SKILL.md` lists the recurring
*shapes* these take in any data-heavy domain — index conventions, identifier forms, padding, structure
that must not be averaged away, label semantics, split construction, provenance — which is a good
starting checklist.

Skip this entirely on a new project and add it when the first silent failure appears.

### c. Decide the review dimensions

The profile declares which dimensions exist (`code`, `biology`, `scope`). A project with no
domain-science component declares no `biology` dimension and deletes `agents/biology-reviewer.md` —
after which no task can assign it.

### Then, in the project itself

Write a `CLAUDE.md` that is a **navigator, not a log**: layout, the gate commands, the spec read order,
and a *Traps* section for failures that look like success. It loads into every session, so every line
costs context permanently.

---

## 2. The loop

```
/spec            the question, the hypothesis,      rare — only when the direction changes
      │          tiered criteria, the levers
      │
/plan            levers → ordered tasks, each       rare — once per spec layer
      │          with Accept/Verify and Review:
      │
/build           do the next task                   the one you type most
      │
/handoff         record the session                 end, or when a lesson is worth keeping
```

Both `/build` and a `master` session orient themselves by reading the active `tasks/todo-<gen>.md`
directly — there is no separate "where am I" command.

`/build` **never starts itself** — it carries `disable-model-invocation: true`, and discussion is the
default mode for everything else. A question stays a question.

### `/spec` — open a layer, never overwrite one

Specs **layer**. A new direction adds a new file (or a dated top-block) that records what it
supersedes; earlier layers stay as the record. `/spec` prints the chain, refuses any path on the
profile's "never write to" list, and stops at `DRAFT` with a diff of what the layer closes, re-opens
and freezes. It writes no plan.

A spec layer must carry: the hypothesis and what would falsify it · a causal chain with every link
graded `measured` / `derived` / `literature` / `assumption` / `open` · **prior work**, with each
published number's dataset, split and metric · tiered success criteria against a named baseline · a
stop rule as a decision table · the lever registry · the review policy.

### `/plan` — levers into tasks you can act on

One task = one lever or one probe. Each lever splits in two so the build is reviewable before it costs
compute:

```
<id>.1  [CPU]             build behind an off-by-default switch; prove the off-path bit-identical
<id>.2  [GPU, ask-first]  one judged run of that switch, and nothing else
```

Every task carries an **`Accept/Verify:`** line that *is* the pass/fail rule, and a **`Review:`** line
naming the reviewers it needs.

The todo's first 40 lines must be an **orientation block**: the target chain (project → phase → why
these tasks), an ASCII pipeline of the current track with `[CPU]`/`[GPU]` and decision points marked,
and a table of the next three actions. Superseded plans are **archived, not kept below** — a dead plan
in the same file ends up reading like the document.

### `/build` — three modes, and it says which one it is in

| Mode | When | Ends with |
|---|---|---|
| **T** | a `[CPU-trivial]` task — no numeric/behavioural effect on any result | gate green → inline scope check → commit and **push** → todo updated → stop. No off-path fixture, no four-test-pattern requirement, no reviewer dispatch by default. |
| **C** | a `[CPU]` task | gate green → inline scope check → the task's reviewers → commit and **push** → todo updated → stop |
| **G** | a `[GPU]` task not yet run | script + run-guide + **pre-registered** pass/fail table → `delivered — NOT RUN` → stop |

Tagging a task `[CPU-trivial]` instead of `[CPU]` is the plan writer's call, by effect, not by diff
size — a config rename is trivial; a one-line change to a loss weight is not, however small the diff
looks. Mis-tag toward `[CPU]` when unsure: the cost of over-tagging is a few extra review minutes, the
cost of under-tagging is a numeric change that shipped with no fixture and no reviewer.

Results are **not** a `/build` mode. A finished run's numbers go to the master.

Mode G never reports a number, never says done, never submits the job. If numbers are pasted into an
implementation session, `/build` says that judging them is the master's job and stops — it will not
write a `RESULT` block or mark a task done.

Every mode ends in a seven-section report whose last section is **`Needed action`**: something to run ·
a next step that is mine and how to start it · a next step that is yours · or one decision question
with a recommendation. A bullet summary is an unfinished turn.

---

## 3. Two session roles

### Setting up the master

The master is a **session-wide agent**, not a command you run once. Three ways in, strongest first:

```bash
# 1. start a whole session as the master (recommended)
claude --agent master
```

```json
// 2. or make it this project's default, in .claude/settings.json
{ "agent": "master" }
```

```
# 3. or take the role mid-session, in an ordinary chat
/master
```

Option 1 applies the role's model and restrictions from the first token, so there is no window in
which the session behaves like a normal chat. Option 3 is a fallback — the role is advisory from
whenever you type it.

**What it is configured with**, in `agents/master.md`:

| Field | Value | Why |
|---|---|---|
| `model` | `opus` | it judges, it does not execute |
| `memory` | `project` | persists across sessions, shared across worktrees |
| `tools` | *(omitted)* | inherits everything — it needs to spawn workers and edit documents |

It deliberately does **not** set `omitClaudeMd`: the master wants the project navigator. The four
workers do set it, because loading 30+ KB of navigation into every review was the single largest cost
in a review.

**Its first turn, every session:** it reads the active `tasks/todo-<gen>.md` directly — the
orientation block, the task list, and the `RESULT` block under each finished task, which carries a
`**Handoff:** <path>` line when a session wrote up the reasoning behind it. It follows that link only
when a question reaches into *why*. Then it reports four lines (Active, Last result, Next, Waiting /
blocked) and stops. Orienting is not permission to start work.

**What you give it:** the numbers that come back from a run, and your decisions at branch points.
Nothing else — it reads the rest itself, or sends `verifier` to find out.

**What it gives you:** a judged result written into the todo, and a prompt to paste into a fresh
implementation session.

**Starting a replacement master.** When one runs low on context it writes a handoff *while there is
still room*, and tells you the path. Start the new one the same way (`claude --agent master`); its
first turn picks up the handoff's `Resume here` block. Memory carries what is costly to re-derive; the
handoff carries the reasoning. Both, not either.

### The division of labour

**Master** — tracks the hypothesis, judges returned results against the pre-registered rule, decides
*with* you, writes handoffs. It does not write code. It delegates fact-finding to the Sonnet `verifier`
rather than running things itself, which is the cost split that makes a long-running master affordable.

**Implementation** — a throwaway session per task, driven by `/build`. It gets the task id, the
biological claim and the `Accept/Verify` line. It does **not** get the handoff or the hypothesis
history; those cost room it needs for the work.

Two rules make the split work:

- **The implementation session never chooses the next lever.** After a build it stops and hands back.
- **The implementation session never judges a result.** Numbers go to the master, which holds the
  pre-registered rule, the noise levels and the routing table. `/build` refuses them.

### Continuity when a session runs out

Project memory holds what is costly to re-derive — the shape of the hypothesis, which levers are spent,
which comparisons are not valid, standing agreements, reversals. It **never holds a number as fact**;
numbers live in the todo and are re-read. When memory and the files disagree, the files win.

Run `/handoff` **while there is still room to write it**. A handoff written from a compacted summary is
where invented rationales come from. If room is very short, write the **`Open threads`** section
first, then the rest of `Resume here`.

**A discussion cut off mid-way is the hardest thing to carry across.** A settled decision survives in
the todo and the code; a half-built argument survives only if it is written down as one. So `/handoff`
records each unfinished thread as: what prompted it · the options on the table · which way the thinking
was leaning, and why · what was **already dismissed**, and why, so it is not re-raised · the unanswered
objection · what would settle it. Without that, the next session resumes the *topic* and re-derives the
argument, often differently.

### The handoff archive is the master's memory of the project

`docs/handoff/` is the reasoning archive, and each folder's `README.md` is its **search index** — every
entry carries what was decided, what was measured, what was reversed, and what must not be re-run.
That is what makes it retrievable months later.

The index has two parts. **`Open threads`** lists unfinished arguments, each pointing at the latest
handoff in its chain — this is what a new session reads first, because a chronological list cannot say
what was being argued when the last one stopped. **`Index`** is newest-first, and each entry's
`Continues:` link makes a chain walkable backwards to where a line of reasoning began. The master
maintains `Open threads`, removing a bullet when the thread is settled.

The master reads the **index**, not the archive, and opens only what it needs — when a question looks
settled but it cannot say why, when a result contradicts an earlier conclusion, before proposing
something that may already have been tried, or when you ask "why did we do X". It answers by quoting
the entry, never by inference presented as its own measurement.

The discipline that keeps this cheap: orientation scans the index and opens **one** handoff, the newest.
Reading the archive at startup spends context on history instead of the work.

So the index entry matters as much as the handoff. `/handoff` writes it as a one-line abstract of what
was *settled*, plus up to four sub-lines — `Decided:` · `Measured:` · `Reversed:` ·
`Do not re-run / do not reopen:` — using words a future session would actually search for: the lever
id, the metric name, the component. Numbers carry their conditions, or they will be misread later as
comparable.

## 4. Reviewer assignment

Reviewers are assigned **per task, by whoever writes the plan** — not by a fixed rule, which would suit
one project and not the next.

```markdown
- **<id>.1 [CPU]** <what changes>
  - **Accept/Verify:** <the pass/fail rule>
  - **Review:** code, biology
```

| Assign | When |
|---|---|
| `code` | almost always — correctness, ported maths, attributability |
| `biology` | the change touches how the domain is represented: residue slicing, chain handling, masking, label or group semantics, a loss encoding a domain claim |
| `scope` | the reviewing session is **not** the one that built it |
| `none` | a pure docs change, or any `[CPU-trivial]` task. Say why. |

`biology` and `code` are **Opus** — seniors reviewing juniors, so a Sonnet implementation session still
gets a senior read. A round costs minutes, which is why three things are bounded: assignment is per
task (a config-flag change needs `code` alone), the assigned reviewers are dispatched in **one
message** so they run concurrently, and there is **at most one re-review**, for a Critical finding
only. The full gate runs **once**, before the commit — not after every review fix.

**Reviewers run on the build, before the commit** — because what they catch is invisible to the test
gate. A residue off-by-one, a mask that lets padding through, a bag label treated as allele-specific:
all pass a green suite. Deferring review would mean the bug is committed and whatever is built on top
has inherited it.

The constraint is therefore **speed**, not whether to review. A review is worth minutes per task, not
an hour: name the risk areas in the delegation, ask for **defects only**, dispatch the assigned
reviewers in one message, allow at most one re-review, and run the full gate once. `code-reviewer` is
Sonnet — finding bugs in a diff is bounded work; `biology-reviewer` is Opus, because judging whether an
operation represents the biology is not.

**Scope is checked inline**, by the building session, because it already holds the plan. Spawning a
blind agent to re-read it pays twice.

`/build` **resolves** findings rather than forwarding them: Critical → fix and re-review (max two
rounds) · Important and cheap → fix in the same turn · Important and not cheap → written into the todo
with an id · only a genuine judgement call reaches you, as one question with a recommendation.

---

## 5. File map

```
.claude/
├── README.md              this file
├── commands/              what you type: spec · plan · build · master · test
├── skills/                the procedures the commands invoke, loaded on use —
│                          `using-agent-skills` carries the routing table and the standing
│                          operating behaviours (build-on-request-only, scope discipline,
│                          communication style) for whichever session loads it
├── agents/                master (opus) · biology-reviewer, code-reviewer (opus, high)
│                          · scope-reviewer, verifier (sonnet) — all four read-only.
│                          `master.md` carries the evidence-grading mindset and the `RESULT`
│                          block shape directly in its own persona — it is the one role that
│                          needs them as a standing habit, not an on-demand lookup.
└── references/            depth on demand, read when a skill or agent points at them
    ├── project-profile.md      ← THE FILE TO EDIT per project
    └── evidence-standards.md
```

Master orients by reading the active `tasks/todo-<gen>.md` directly — no separate orientation
skill. `/start-session` was dropped along with it.

**Where a thing belongs.** Nothing is loaded into every session unconditionally — there is no
`rules/` folder. A multi-step procedure → a skill, loaded when invoked. A standing behaviour that only
one role needs as a permanent habit → that agent's own file (evidence grading → `master.md`). A
standing behaviour several session types need, but only on demand → `using-agent-skills`, invoked when
a task's routing is unclear. Project-specific data a skill or agent points at by name →
`references/project-profile.md`, never duplicated elsewhere.

---

## 6. Advisory, not enforced

Per Claude Code's own documentation, rules and `CLAUDE.md` are *"context, not enforced configuration."*
Everything here raises the odds a rule is followed; none of it guarantees it. Two mechanical levers, if
a rule keeps slipping:

- **A hook.** The documented fix for a rule that must hold every time — a `PreToolUse` hook blocks an
  action regardless of what the model decides.
- **`permissions.deny` in `settings.json`.** Denying the submission commands would make "the researcher
  submits every job" mechanical rather than a promise. Not configured here.

## 7. Case study — the project this was built in

`pocketscope-v2`: predicting MHC-II antigen presentation. Several sibling subprojects, a shared data
corpus, two Slurm clusters the researcher submits to, and a reference model to beat. Every rule here
came from something that went wrong in it.

**How the pieces map:**

| Config concept | In this project |
|---|---|
| spec layer | `SPEC.md` → `SPEC-arch-v2` → `SPEC-training-perf` → `SPEC-gen2` *(stopped)* → `SPEC-gen3` *(active)* |
| lever | one entry in `SPEC-gen3` §9 — `G7` input-norm, `G8` decay exemption, `G10` allele-aware loss |
| judged run | one arm, one fold, on blackwell or l40s |
| pre-registered rule | the pass/fail table in `docs/run-guides/<arm>.md` |
| verdict | `done` · `done-negative` · `void` in `tasks/todo-gen3.md` |

**One real cycle, B-onehot → B-trim:**

1. `/plan` ordered B-onehot as the next arm, `[CPU build → GPU]`.
2. `/build` Mode C built it behind a default-off flag, proved the off-path bit-identical, ran the gate.
3. `/build` Mode G shipped the runner, the run-guide, and a threshold table fixed before any numbers.
4. The researcher submitted it. It came back **negative** — the score regressed to peptide-only.
5. The **master** judged it: valid run, failed the pre-registered rule → `done-negative`, recorded with
   its `Limits:`. But the diagnostics localised the cause: `ctx` was healthy at groove-tracking 0.79
   while the 32-slot pooling collapsed it to 0.37.
6. The routing table said the pooling, not the one-hot, is the bottleneck → next arm **B-trim**.

A negative result that moved the work forward. The config's job was to make step 5 decidable rather
than a judgement call, and to stop step 6 being chosen by the session that built step 2.

**One real master session, and the handoff that continued it:**

A single master session covered three things, then ran low on room mid-way through the third:

1. Restructured `todo-gen3.md` — current tasks promoted, superseded ones blocked off. **Settled.**
2. Judged B-onehot's returned numbers, wrote the `RESULT` block, routed to B-trim. **Settled.**
3. Started discussing *how* to build B-trim — and was cut off **mid-argument**.

What each one needed to survive:

| | Carried by | Reconstructable without it? |
|---|---|---|
| 1 and 2 | `Decided:` / `Measured:` in the handoff and its index entry | yes — the todo and the diff show them |
| 3 | **`Open threads`** | **no** — nothing else holds a half-built argument |

So the handoff wrote the thread: the options on the table, which one it was leaning toward and why,
what had already been dismissed and why, the objection still unanswered, and what would settle it.

The next `claude --agent master` then read the index, opened that handoff, and **continued the B-trim
argument** instead of re-deriving it — and did not re-propose the option that had already been dropped.

That is the test of this setup: not whether a new session knows the project state, but whether it can
pick up an unfinished argument. State survives in files on its own. An argument does not.

**Failures that produced specific rules:**

| What happened | Rule it produced |
|---|---|
| `/spec` instructed writing to root `SPEC.md`, which holds an archived spec | profile's *Never write to*; `/spec` refuses those paths |
| An unapproved "allele screen" was built *and written into the plan as a task*, then reverted | a task is buildable only if it has a plan id; proposals are labelled, never written in |
| A next-steps menu omitted two ordered tasks → an arm ran at an untuned LR, ~6 GPU hours, verdict **void** | a menu must list every earlier unchecked task and the cost of skipping it |
| A reference checkpoint that had seen the test peptides read 0.944 against an honest 0.7327 | a paper's or a checkpoint's number is not a baseline until its conditions match |
| Plain `Adam` folded weight decay into the gradient and erased weights with no task gradient | set-equality on parameter groups, asserted both directions |
| A handed-over runner was silently revised after delivery; the old one was already running | name the superseding commit **before** pushing |
| Half of `todo-gen3.md` became a dead plan, with live work in a blockquote | superseded plans are archived; an orientation block goes in the first 40 lines |
| A build committed first, then reviewed, then handed back a menu of fixes | review before commit; resolve findings, never forward them |

## 8. Known gaps

- The agents' review quality by model (Opus versus Sonnet) is **unmeasured** — an `assumption`. To
  test: send the same diff to both and compare findings.
- `references/` still carries worked examples from one project. The rules transfer; the numbers are
  illustrative and should be swapped.
- `hooks/hooks.json` and `hooks/session-start.sh` in this repo have never executed — project-level
  `hooks.json` is not read, and `${CLAUDE_PLUGIN_ROOT}` is unset outside a plugin. Only
  `handoff-reminder.sh`, wired through `settings.json`, works.
- `hooks/SIMPLIFY-IGNORE.md`, `simplify-ignore.sh` and `simplify-ignore-test.sh` are also orphaned —
  never wired into `settings.json`, and the `/code-simplify` command they protected against has since
  been removed. Dead until both are rebuilt together, or deleted.
- Nothing here has been exercised across a full `/spec → /plan → /build → /handoff` cycle on a fresh
  project.
