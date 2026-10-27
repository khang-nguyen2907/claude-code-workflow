# Investigation-layer spec template

For a project that answers questions rather than training a model. Shape taken from `eda_src/SPEC.md`.

---

# SPEC — <project>: <what we are trying to understand>

> **This is an investigation, not a model.** Nothing in this spec designs, trains, or benchmarks a
> predictor. Its single purpose is to *understand*, by computing on real molecules and real data.
> Architecture decisions are explicitly **out of scope** and downstream of this work.

**Status:** DRAFT (opened <date>) · **Layers on:** <what it informs> · **Not:** <exclusions>

## 1. Objective
The questions, in priority order. What a finished investigation lets us *say*.

## 2. Scope
Data tiers × data types. Mark corrections inline and dated:
*"**Correction (<date>, T0.1):** <what was assumed, what is actually true>."*

## 3. Investigation plan (probes)

The unit of work is a **probe**, not a feature. Each probe produces (a) a notebook and (b) a short
report in `docs/reports/`. **Ordering is cheap → expensive; each tier earns the next. `[D<n>]`**

**Workstream A — <the ladder>:** `A0 … A<n>`, each with a one-line **Deliverable:**.
**Workstream B — <the other>:** `B0 … B<n>`.
They **meet at** <where>.

Include at least one **contrast probe** — build an honest negative, run the same measurements on both,
and *watch which measurements move*. A measurement with no contrast establishes little.

## 4. Toolchain
What is installed when. Every heavy install sits behind an **ask-first** gate.

## 7. Code style · ## 8. Testing
Unit-test every **metric definition** whose number will be quoted in a spec.
Fixed seeds for any sampling or clustering; **record tool versions in each report.**
Frame physics/energy outputs as **relative**, never absolute.

## 9. Boundaries
**Always** · **Ask first** · **Never**. Shared data is read-only.

## 10. Locked decisions + open items
`[D1] … [D<n>]` inline, plus what is still unsettled.

---

## Report conventions (declare these here)

**Architecture-implication footer.** Every A/B report ends with one line —
**"Architecture implication (`<spec>` `<id>`): …"** — naming which decision the finding informs, or
"none" with a reason. A finding that informs nothing is still recorded, with that said plainly.

**Findings can bound a claim rather than enable one.** e.g. *"if test negatives are random decoys,
'beating <baseline> on test' partly measures decoy-detection, not binding."* That is a result.
