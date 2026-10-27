# MODE C: a `[CPU]` task

Not test-first. For a change that affects a number, the right answer is unknown until it runs, so first prove that nothing *else* changed.

1. **Switch, off by default.** Add the new capability as a config field whose default is the old behaviour.
2. **Off-path proof.** Regression test: with the switch off, output is bit-for-bit identical to the old forward pass. This is what makes "one change per judged run" true.
3. **On-path tests:**
   - a property that holds across scales, not one fixed number
   - something that should *not* change, checked with and without the change
   - the same parameters appearing on both sides of a set-equality check
   - the metric's own formula has not quietly changed

   State the tolerance on every float check. Fix the seed on every test using randomness. (More detail: `test-driven-development`.)
4. **Build gate, run once.** Unit tests + only the smoke tests this change touches + lint + type check (about 2 min). Never run the full smoke suite (reserved for GPU delivery). Never run two gates at once. Never make a task whose only job is to wait for a running gate.
5. **Review.**
   - Self-check scope first: plan id, the one real behaviour change in the diff, off-path proven identical, `Accept/Verify` checked item by item, out-of-scope flagged.
   - Then send the task's `Review:`-tagged reviewers via `review-team`, all in one message, real problems only, telling them exactly what to look at.
   - Critical finding: fix it, same reviewer rechecks **once**. Still Critical: **stop and ask the researcher.** Do not retry or ship anyway.
6. **Fix findings yourself.** Critical: fix + recheck once. Important and easy: fix now. Important but hard: log in the todo with an id. Never hand back a list you could have fixed.
7. **Commit, then push** to `origin` on the current branch without asking. Code auto-pushes; documents do not (`project-profile.md`, *Commit policy*). If a commit would mix both, split it in two.
8. **Update the todo:** what landed, and plainly whether `Accept/Verify` was met.

Then report using *Closing report* in `SKILL.md`. **Stop there.** Do not start the next task, check off a parent task, or write an unapproved idea into the plan.

**`[CPU build -> GPU]` tasks:** this mode covers the Build half only. The GPU half is always a separate turn. In **Needed action**, say so and name exactly what the run half still needs before it can go out.
