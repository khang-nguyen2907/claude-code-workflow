# Evidence standards

This is research. A claim is not true because it sounds right, because the architecture suggests it,
or because it appeared in a previous reply. **Every claim carries a grade, and the default grade is
not "true".**

## The five grades

Tag every substantive claim. Written as `[measured]`, `[derived]`, `[literature]`, `[assumption]`,
`[open]`.

| Grade | Means | Required with it |
|---|---|---|
| **`measured`** | A number exists, produced by a run or a script in this repo | the number, and the file/script that produced it |
| **`derived`** | Follows from a `measured` thing by stated argument | the argument, in one or two steps, and which measured fact it rests on |
| **`literature`** | Published elsewhere | the citation **and the conditions** — dataset, split, metric, n |
| **`assumption`** | Believed, not checked | what would check it, and the cost of checking |
| **`open`** | Not known | what measurement would settle it |

**An inference written as a measurement is the failure to avoid.** It has happened here: *"A0.4's 'gap
leans peptide-side' was reversed by D1 … so 'the gap is allele-side' is an inference"*
(`2026-10-18` handoff).

## Source strength, strongest first

1. Own measurement on the real data, with a pre-registered rule
2. Own measurement on real data, post-hoc
3. Own measurement on synthetic input (proves the code, not the biology)
4. Peer-reviewed paper, with the split and metric checked
5. Preprint, same check
6. The reference implementation's code (`immuscope_src/assets/`, `cmhs_src/assets/`) — what it *does*, not what its paper *says*
7. Documentation
8. Biological plausibility — real evidence, but weak on its own; label it and say why it is plausible
9. Architecture intuition — **not evidence.** Label it `assumption` or leave it out

A claim at grade 8 or 9 never outranks a measurement. When they conflict, the measurement wins and the
conflict gets recorded.

## Rules

**A number from a paper is not a baseline until its conditions match.** Record dataset, split, metric
definition, and n alongside it. Numbers measured on different splits are not comparable, and treating
them as comparable is the most expensive mistake available. The project's own reference numbers and
their conditions are in `references/project-profile.md` → *Reference numbers*. Two instances from one
project, as illustration:

- `immuscope_src/weights/EL/ImmuScope-EL-0-*` scores group AUPR **0.944** because it saw the fold-0
  test peptides; the honest number on the same model is **0.7327**. Using the wrong checkpoint makes a
  model look 0.2 better than it is.
- The field's headline 0.85–0.95 figures are largely interpolation: 73–83% of "novel" test alleles have
  a ≥0.95-identity training near-twin (`SPEC-gen3.md`). So "we are far from the state of the art" may
  be comparing against a number that does not mean what it appears to.

**"It is well known that…" is an assumption until two independent sources say it.** One paper is
`[literature]` with that paper's conditions; it is not the field's consensus.

**Before an expensive run, check whether the question is already answered.** Searching the literature
costs minutes; a GPU arm costs hours and a slot on a shared machine. Ordering cheap evidence before
expensive evidence is already the rule for investigation probes (*"cheap → expensive; each tier earns
the next"*) — it applies to literature too.

**Disagreeing with published work is allowed.** State what they measured, what we measured, under which
conditions, and **what experiment would settle it**. Do not resolve a conflict by preferring whichever
result is more convenient.

**A published negative result is evidence.** So is a method the field tried and dropped. Finding that
something was already tried and failed is a result worth recording, not a dead end.

**Biological plausibility has to be stated, not implied.** If a mechanism is proposed, say what it
means for the molecule: which residues, which chain, which part of the groove, and why that would
change binding. A mechanism that cannot be stated in those terms is `[assumption]`.

## Where to get external evidence

- `literature-review-consensus` — a review on a topic
- `overview-paper` — read one paper, plain-English, for recall
- `research-paper-auditor` — methodology audit, gaps, hidden assumptions
- `paper-to-code-spec` — a paper's Methods, for implementation
- The **Consensus** paper-search tool, when available, for ranked peer-reviewed results

Cite what comes back with its conditions. A search result is `[literature]`, never `[measured]`.

## Anti-patterns

- Comparing a number against a baseline measured on a different split
- Quoting a paper's headline number without its split, metric and n
- Writing `derived` as `measured`, or `assumption` as `derived`
- "The literature shows…" with no citation
- Reasoning from the architecture to a conclusion and stating it flat
- Proposing a mechanism with no molecular statement behind it
- Running an expensive arm to answer something a paper already answered
- Dropping a result because it disagrees with the literature, or keeping it only because it agrees
