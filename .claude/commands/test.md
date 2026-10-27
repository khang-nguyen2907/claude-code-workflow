---
description: Run the pre-flight verification — off-is-bit-identical fixture, property/invariance tests with controls, seeds and tolerances, then the gate. Not the verdict on a hypothesis.
---

Invoke the `test-driven-development` skill.

**Order** (not test-first — for a numeric change the expected value is often unknown until it runs):

1. Implement behind an **off-by-default** config switch.
2. Prove the **off-path is bit-identical** to the pre-change forward (regression fixture). This is what
   makes an arm's result attributable to one change.
3. Add the on-path tests, by pattern:
   - **property across scales**, not a golden number
   - **invariance plus its control** — assert the arm that should *not* be invariant isn't
   - **set-equality on parameter groups**, asserted both directions
4. Unit-test the **metric definition** of any number that will be quoted in a spec or RESULT block.
5. Run the gate: `uv run pytest tests/unit tests/smoke -q` · scoped `ruff` · `mypy` at the recorded
   baseline count (add none).

Every float assertion states a tolerance and why. Every stochastic test fixes its seed. Never loosen a
tolerance or retry to get green — record the spread and widen the margin the *verdict* requires.

**A green suite means "safe to submit", not "the idea works."** The verdict is a number against a
pre-registered threshold, recorded in a `RESULT` block.
