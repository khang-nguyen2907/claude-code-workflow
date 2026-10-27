---
name: test-driven-development
description: Pre-flight verification for numeric, stochastic model code: off-is-bit-identical fixtures, property and invariance tests with controls, seeds and stated tolerances, metric-definition regression. Use when implementing or changing model, loss, optimizer, config or diagnostic code. Tests here prove the code does what was claimed; they are never the verdict on a hypothesis.
allowed-tools: Read Write Edit Bash Glob Grep
---

# Accept / Verify: the pre-flight

**Tests prove the code does what I said. They never prove the idea works.** The idea is judged by a number against a pre-registered threshold, on a GPU run, recorded in a `RESULT` block, by the master session (`agents/master.md`).

```
tests/unit   deterministic, CPU-only                  -> code does what I said
tests/smoke  tiny synthetic fwd/bwd, mini-epoch, gloo -> runs end to end
ruff, mypy   at the recorded baseline                 -> nothing regressed structurally
all four together = PRE-FLIGHT, never the verdict
```

A green suite on a `[GPU]` task means "safe to submit" only. Status stays `delivered, NOT RUN`.

## Order (not test-first)

The expected value of a numeric change is usually unknown until it runs, so first prove **nothing else changed**:
1. Implement behind an off-by-default switch.
2. Prove the off-path is bit-identical.
3. Add property / invariance / set-equality tests for the on-path.
4. Run the gate.
5. Commit and push code only, never documents (`incremental-implementation`, Mode C step 7).

## Four fixture patterns (use by name)

1. **Off-is-bit-identical.** New capability behind a config switch defaulting to old behaviour; off-path bit-for-bit equal to the pre-change forward. This enforces *one change per judged run* in code; without it the arm is unattributable and its verdict is `void`. Instances: `input_norm: false` vs hand-written pre-G7 forward; `interaction: iconv_aligned` vs pre-G1; `exempt_attention_from_decay: false` vs plain Adam (`tests/unit/test_chain_fusion.py`, `test_optim.py`).
2. **Property across scales, not a golden number.** Assert the invariant (e.g. `input_norm: true` gives `ab` rows of ~sqrt(d_model) at input scales 0.01 / 1 / 100). A golden number from one run makes today's behaviour, bugs included, the spec.
3. **Invariance plus its control.** Assert the invariance *and* that the arm that should not have it does not (e.g. shuffling the 32 conformation tokens leaves `z_rep` unchanged for `iconv_dynamic`, and `iconv_aligned` is asserted *not* invariant). An invariance test with no control passes equally when the input is ignored (dead slots, washed-out `ctx`).
4. **Set-equality on parameter groups, both directions.** The no-decay group holds exactly the intended parameters and nothing else. Catches unintended inclusions, e.g. `nn.MultiheadAttention` packing Q/K/V into one `in_proj_weight`, so exempting W_q/W_k silently exempts W_v (`tests/unit/test_optim.py`).

## Domain traps (fail silently, return a plausible number)

Before writing tests, ask what could be wrong yet still give a believable result, and test each:
- **Index/coordinate conventions:** offsets and reference numbering differ; a wrong offset keeps the right shape. Assert **content** at a boundary, not length.
- **Identifier forms:** multiple valid spellings/prefixes/depths cause silent lookup misses. Unknown identifiers must **raise**.
- **Variable length, padding, masking:** reductions over padded axes must mask. A batch of two real lengths must equal the entries run singly.
- **Order-bearing structure:** an operation invariant to order discards meaning. For a genuine unordered set, invariance is correct but needs a control proving the ordered case is not.
- **Label semantics:** a label about a group is not a label about a member; check what the label asserts vs what the loss assumes.
- **Split construction:** train/test independent under the domain's similarity measure.
- **Provenance:** data passed its integrity check; tool versions recorded with any quoted number.

Project-specific list: profile, *Domain pitfalls*.

## Metric definitions get their own tests

Any number quoted in a spec or `RESULT` block needs its definition pinned (`tests/unit/test_ctx_scale_metrics.py`, `test_allele_shuffle.py`, `test_tier0_report.py`). Also reproduce a published number from a committed checkpoint to a stated tolerance. Precedent: `measure_ctx_scale` rebuilt the fusion input by hand and ignored `input_norm`.

## Seeds, tolerances, variance

- Every float assertion states its tolerance **and why**. Every stochastic test fixes its seed. A claim across seeds names them (A0.1: 2024 / 7 / 99).
- One seed is a measurement; repeated across seeds is a finding.
- Known spreads: checkpoint-selection ~±0.03, fold SD ~±0.02, allele-shuffle ~±0.007. These enter the pre-registered threshold (a 0.02 "win" is inside selection noise).
- **Never** retry until green. **Never** loosen a tolerance to pass: record the spread and widen the margin the *verdict* requires. Report real stochastic spread, do not suppress it.

## Never automated

No automated test downloads real weights, reads the real HLA cache, or trains on real data (cost, credentials). Real-cache diagnostics are manual `scripts/` tools, run on request, outside the gate (root `CLAUDE.md`; `swiftscope_src/SPEC.md` §6).

## Exploratory code is legitimate

A `scripts/` probe answering one question, reported in a `RESULT` block, need not become production code. It needs: unit tests on its **metric definitions**, a line in the todo, and an explicit `Limits:`. (This reverses the old "prototypes become production code" rule; here probes are a deliverable.)

## The gate

Exact commands, test-directory split and type-check baseline count: `.claude/references/project-profile.md` -> *The gate*. Do not assume them. Always:
- The type-check baseline is a **count, not zero** if the repo has pre-existing errors. Add none; report the number you saw.
- Lint and format scope: package and tests, never repo root.

## Never

- Treat a green suite as the verdict on a hypothesis.
- Write an invariance test with no control.
- Use a golden number where a property belongs.
- Leave a float assertion without tolerance, or a stochastic test without seed.
- Loosen a tolerance or retry to get green.
- Assert set-equality in one direction only.
- Quote a diagnostic's number when its definition has no test.
- Demand production-grade tests from a one-question probe.
