# Run-guide template

Save to `docs/run-guides/<id>-<slug>-<machine>.md`. Submission adapters, log locations and the
pre-run data check come from `.claude/references/project-profile.md` → *Compute*.
**Every section is required.** The researcher runs this without you present.

---

# <id> — <the question this run answers>? Run guide (<machine>)

**What runs:** <config name> · <N> GPUs · fold <k> · <stages> · ~<duration>
**Script:** `<the runner>` submitted through the project's submission adapter

## 1. Before you submit (login node, no GPU)

```bash
git pull && git log -1 --oneline        # expect <commit subject>
<the project's data-integrity check — profile → Compute>
#   must print that the data matches the committed manifest
ls outputs/<run>                        # must say "No such file"
```

- **If `outputs/<run>` exists, move it aside.** `CheckpointManager.load` is `strict=False`, so a shape
  mismatch after a config change **loads silently wrong instead of erroring.**
- `export HF_TOKEN=<...>` if the run touches a gated model.

## 2. Smoke test first (10–20 min, recommended)

```bash
<the smoke command, with the smoke config>
```
Expect: <the sentinel line — the exact line the log prints only when the run finished cleanly>. If
the smoke fails, stop — do not submit the official run.

## 2b. On a shared machine

Read the smoke run's peak, then request **largest reserved + a margin**. Never request the whole
card: other people need it.

## 3. Submit

```bash
<the project's submission adapter> <args> --dry   # inspect the generated submission first
<the project's submission adapter> <args>
```

## 4. Running, done, or failed?

- **Running:** <the project's queue-status command>
- **Done:** the log ends `<the exact sentinel line>`
- **Failed:** anything else. **Send the last 40 lines; do not resubmit blindly.**
- Logs land at: <the path the profile names for this machine>

## 5. Report back (exact paths)

1. <the exact file>, <which row/field> — this is **<symbol>**
2. `cat <exact path>` — gives **<symbol>**
3. <the block printed at the end of the log>
4. `grep -i nan <logfile> | head -3` (should print nothing)

## 6. Pass / fail (fixed now, before the numbers exist)

**Valid run:** ends `<sentinel>`, the output file exists, no NaN.
<Any known-benign anomaly, named explicitly so it is not read as failure.>

**References:** <baseline> = <number> · <reference model> = <number> · selection noise ≈ ±<x>

| <symbol A> | <symbol B> | reading | next |
|---|---|---|---|
| | | | |

**Weights still alive after the run:** <the named checks and their floors>. If any fails, <which
checkpoint does not hold>, and I diagnose which stage drove it before any further lever.

These cut-offs are my proposal; tell me now if you want any changed. **They must not move after you
see <symbol A> and <symbol B>.**
