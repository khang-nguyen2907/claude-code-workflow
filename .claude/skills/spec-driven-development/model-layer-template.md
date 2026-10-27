# Model-layer spec template

Section list taken from `SPEC-gen3.md`. Keep the numbering so the layout never has to be relearned.

---

# SPEC-<gen> — <project>: <the question, in one line>

> ## ⟐ CURRENT DIRECTION (<date>) — the operative top layer
>
> This block **supersedes** <what, by section/id>. Everything below it is **kept as the record** of how
> <gen> reached here — read it for the measured evidence, not for the current plan. Full reasoning:
> [`docs/handoff/<date>-<slug>.md`](...).
>
> ### What changed, and why
> <the measurements or outside evidence that forced the change>
>
> ### Revised objective / primary target
> - **PRIMARY:** <the number, the data, the baseline, the margin>
> - **SECONDARY (diagnostic, not the headline):** <and why it is demoted — e.g. gameable, redundant>
> - **DELIVERABLE:** <what is claimed in the end>, **not** <the thing it is easily confused with>
>
> **⚑ SCOPE NOTE (researcher, <date>):** <what is explicitly deferred to lowest priority, and the
> condition under which it gets built>

**Status:** DRAFT (opened <date>)

**Layers on:**
- `<file>` (`<ids>`) — **kept:** <what still holds>; **closed:** <what this layer settles or retires>

**Not:** <the explicit exclusion list — name the stale root `SPEC.md` here if relevant>

**What is frozen going in (do not reopen):** <list>

**Numbering bridge (<date>).** The pre-revision **<old id>** is *superseded*, not renamed: its job is
split into **<new>** and **<new>**. Documents still citing "<old id>" refer to this superseded lever.

---

## 1. Objective

The hypothesis, and what would falsify it.

**The diagnosed blockers, as one causal chain.** Tag every link:

| # | link | grade | evidence |
|---|---|---|---|
| 1 | <claim> | `measured` | <number + file/script that produced it> |
| 2 | <claim> | `derived` | follows from (1) because <argument> |
| 3 | <claim> | `open` | not measured — <what would measure it> |

## 2. Tech stack
Only what *changes* in this layer.

## 3. Commands
Two columns: **local/CPU** (free) and **Slurm** (`bin/submit_{l40s,blackwell}.sh`, ask-first).

## 4. Project structure
Only the surfaces this layer touches.

## 5. Code style
Port with a `file:line` citation; flag every deliberate deviation as a decision, never a cleanup.

## 6. Testing strategy
Unit / smoke / what stays **manual** (real weights, real cache, real data) / what is reported back per arm.

## 7. Boundaries
**Always** · **Ask first** (with spent + rejected approvals on record) · **Never**.

## 8. Success criteria

**Tier 0 — <the mechanism is alive>.** Read off the run's own per-epoch checkpoints — no extra
training. Bracketed numbers are the current baseline, i.e. what each check must clearly beat:
- <check> — <direction> [<baseline>]

**Tier 1 — Convergence (the floor; "does the model train").**

**Tier 2 — PRIMARY: <the headline>.**
- <metric> past <baseline number>, paired over folds.
- **Making a win defensible.** State the noise first: selection swing ±<x>, fold SD ±<y>, n=<k>
  Wilcoxon floor p=<p>. **Pre-register** one fixed selection rule applied identically to both models;
  require sign-consistency; report a second, standard metric as a cross-check.

**Tier 3 — Mechanism (post-win).** Sequenced after the headline, **not abandoned**.

**The stop rule.**

| <observable A> | <observable B> | reading | next |
|---|---|---|---|
| | | | |

If a previous stop rule is being replaced, say so and say why it would have fired for the wrong reason.

## 9. The change, and the open decision registry (the spine)

| id | phase | change | why | status |
|----|-------|--------|-----|--------|
| **<id>** | <A/B/C/D> | <the one isolated change> | <the measured reason> | **OPEN / FALLBACK / DROPPED / DEFERRED / DONE <date>** |

**Open sub-decisions (resolve in PLAN/at the arm, with evidence):**
- <the choice, the options, and what evidence settles it>

**Build order.** Each phase is gated: a later phase is not judged while an earlier Tier-0 check fails.

## 10. Plan / Tasks

Pointer only → `tasks/plan-<gen>.md` · `tasks/todo-<gen>.md`.
**Check the todo before assuming any component's state.**
