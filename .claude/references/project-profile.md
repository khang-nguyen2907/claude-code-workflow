# Project profile

**This is the only file to edit when reusing this `.claude/` in another project.** Everything else —
skills, commands, agents, the other rules — is written generically and reads its specifics from here.
If a skill ever hardcodes a path, a command or a number, that is a bug in the skill: move it here.

Fields a skill may refer to are in **bold**. Delete a section that does not apply and say so, rather
than leaving a stale value.

---

## Identity

- **Kind of work:** research — hypothesis → experiment → measurement → decision. The deliverable is a
  finding, not a shipped feature.
- **Domain:** computational biology / bioinformatics (pMHC-II antigen presentation).
- **Review dimensions available:** `code`, `biology`, `scope`. A task's `Review:` line may name only
  these. A project without a domain-science component declares no `biology` dimension.
- **Domain pitfalls:** *(optional)* if this project has recurring domain mistakes that fail **silently**
  — returning a plausible wrong number rather than crashing — list them directly below, or in a short
  file under `references/` if the list grows, and name it here. Leave this blank if there is no such
  list yet.

## Layout

- **Workspace style:** multi-project — several sibling subprojects under one root, with a shared
  `data/`.
- **Active subprojects:** `swiftscope_src` (model), `eda_src` (investigation, not a model).
- **Reference-only, never edited:** `immuscope_src/assets/`, `cmhs_src/assets/`.
- **Stopped, preserved as record:** `archive/*`.
- **Navigator per subproject:** `<subproject>/CLAUDE.md`. Its *layers* block is authoritative for spec
  read order.

## Spec and task files

- **Spec style:** layered. A new direction adds a new layer; earlier layers are kept as the record and
  never edited. The chain is listed in the subproject's `CLAUDE.md`.
- **Never write to:** root `SPEC.md` and root `tasks/plan.md` — both are stale archived documents.
- **Spec path:** `<subproject>/SPEC-<layer>.md`, or root `SPEC-<gen>.md` for a whole generation.
- **Task paths:** generational subprojects use `<subproject>/tasks/plan-<gen>.md` and
  `tasks/todo-<gen>.md`; non-generational ones use `tasks/plan.md` and `tasks/todo.md`.
- **Superseded task records:** `<subproject>/tasks/archive/`.
- **Session logs:** `<subproject>/docs/handoff/`, workspace-level ones at root `docs/handoff/`. Each
  folder's `README.md` is its index and must be updated on every write.

## The gate — what "verified locally" means

Run from inside the subproject. **Two gates, not one.**

**Build gate** — after every change. Must stay under ~2 minutes.

```bash
uv run pytest tests/unit -q                      # 76 files, deterministic, CPU, fast
uv run pytest tests/smoke/<the files your change touches> -q
uv run ruff check src/<pkg> tests && uv run ruff format src/<pkg> tests
uv run mypy src/
```

**Full gate** — once, before a GPU delivery, and before promoting a result.

```bash
uv run pytest tests/unit tests/smoke -q          # ~25 min: 14 of 25 smoke files run
                                                 # training loops, DDP, real encoders, optuna
```

**Never run the full smoke suite on an ordinary build.** It is 25 minutes to re-prove things the change
did not touch. Running it on every build, sometimes more than once, was measured as the single largest
cost in a build.

- **Test split:** `tests/unit` deterministic and CPU-only · `tests/smoke` tiny synthetic
  forward/backward and mini-epochs — but several of them train, shard across devices, or load real
  encoders, which is why they are not part of the build gate.
- **Type-check baseline:** a **count, not zero** — `swiftscope_src` carries ~69 pre-existing errors.
  Add none. Read the current number from the subproject's `CLAUDE.md`.
- **Environment:** `uv`. Workspace members sync with `uv sync --all-packages` **from the root**.

## Compute

- **Local machine has no GPU.** Every GPU run happens on a server, submitted **by the researcher**.
- **Submission:** through `bin/submit_l40s.sh` or `bin/submit_blackwell.sh`; all GPU work goes through
  Slurm. Agents and sessions never run `sbatch`, `gsub`, `srun` or `grun`.
- **Where logs land:** `~/gjobs/` (l40s) · the `--output` path (blackwell).
- **Shared machines:** request the memory measured from a smoke run plus a margin, never the whole
  card.
- **Data integrity check before any run reads data:** `python -m <pkg>.scripts.data_track check`.

## Reference numbers

Quote these only with their conditions; numbers from different splits are not comparable.

| What | Value | Conditions |
|---|---|---|
| Reference model, honest | group AUPR **0.7327** | fold 0, 5% tier, leakage-controlled checkpoint |
| Reference model, leaked | group AUPR **0.944** | same model on a checkpoint that saw the fold-0 test peptides — **not a baseline** |
| Checkpoint-selection noise | ≈ **±0.03** | larger than many plausible wins |
| Fold standard deviation | ≈ **±0.02** | |
| Published figures for this task | 0.85–0.95 | largely interpolation; most "novel" test alleles have a high-identity training near-twin |

## Ask-first

Real model weights · real training data · GPU time · a new dependency · an on-disk format change.
Spent and rejected approvals are recorded in the subproject's `CLAUDE.md` under *Ask-first*.

## Commit policy

**Code is committed and pushed without asking — standing authorization, do not ask each time. Documents
are left for the researcher, never pushed.** This workspace works on `main`; do not create a branch
unless asked.

| Pushed to `origin` on the current branch, no asking | Left uncommitted for the researcher |
|---|---|
| `src/**` · `tests/**` · `bin/**` · `configs/**` · `scripts/**` | `SPEC*.md` · `tasks/plan*.md` · `tasks/todo*.md` |
| | `docs/handoff/**` · `docs/reports/**` · `docs/run-guides/**` |
| | `.claude/**` · any `CLAUDE.md` |
| | `data/MANIFEST.yml` (has its own `data_track commit`) |

Why code auto-pushes: the GPU servers pull from GitHub, so unpushed code cannot be run.

If a commit would mix code and documents, **split it**: push the code, report the documents as left
for the researcher. If a push fails, say so plainly — never leave the researcher thinking the server
can pull it. A commit happens **after** the review team has run, never before (`/build` Mode C).
