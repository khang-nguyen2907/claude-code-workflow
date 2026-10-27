# MODE G — a `[GPU]` task, before it has run

You never run this yourself — the researcher does. **Calling it "done" is the worst mistake you can
make here.** The honest status is always `delivered for <server> — NOT RUN`.

Hand over all three together, or it isn't finished:

1. **A runnable script** — submitted through the project's own submission method, naming one
   specific machine to run on (`project-profile.md` → *Compute*).
2. **A run-guide** at `docs/run-guides/<id>-<slug>-<server>.md` (`run-guide-template.md`, every
   section filled in).
3. **A pass/fail table, fixed before the run** — written into that guide, ending with: *"these
   cut-offs are my proposal; tell me now if you want any of them changed — they can't move once you
   see the numbers."*

**Review it before handing it over.** Send the task's `Review:`-tagged reviewers through
`review-team`, all in one message. A GPU run costs hours on a machine other people are waiting to
use, so this is where a review clearly earns its cost. A Critical finding blocks the handover; you
get one more check, scoped to just that finding, and if it's still Critical after that, **stop and
ask the researcher** instead of sending it anyway. Only review again here if the handover itself
added new logic — a new config, a changed runner — not if it's just packaging code that was already
reviewed at the CPU build.

Set the todo to **`delivered for <server> — NOT RUN`** and stop there.

**Never, in this mode:** check the task off as done · say "done," "complete," or "working" · report
a number · submit the job yourself (the off-limits commands are listed under *Compute*) · soften a
cut-off after you've already written it down.

**If a script you already handed over needs to change, say so before you push the change.** Name
which commit is now outdated, which one replaces it, and that the researcher needs to pull again —
they may already be running the old one.
