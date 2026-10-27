# MODE T — a `[CPU-trivial]` task

Only for a change with **no effect on any number or behaviour**: a config value, renaming a CLI
flag, a docs or comment edit, wiring a script to code that's already been reviewed, a refactor that
only touches tests. Anything that touches the model, the loss, the optimizer, the data pipeline, or
how a metric is defined counts as `[CPU]` instead, no matter how small the diff looks.

**If, while building it, you find it actually does affect something — stop.** Rebuild it as `[CPU]`
(Mode C) instead. A task tagged wrong by mistake still needs the real scrutiny; being tagged
"trivial" doesn't excuse skipping it.

1. **Make the change.**
2. **Run the build gate once** — same as Mode C, step 4.
3. **Check scope yourself** — same as the scope part of Mode C, step 5. Still free, still no
   reviewer needed for this part.
4. **Skip the off-path test, the four test patterns, and the default reviewer dispatch** — none of
   that catches anything on a change with no numeric effect. Only send a reviewer if the task's
   `Review:` line names one by name. No `Review:` line here means **no reviewer** — unlike Mode C,
   where no line defaults to a code reviewer. A task correctly tagged trivial has earned that.
5. **Commit, then push** — same as Mode C, step 7.
6. **Update the todo.**

**Report only sections 1, 2, 5, and 7.** Sections 3, 4, and 6 each shrink to one line (for example,
`N/A — no biological claim`) instead of being padded out with prose.
