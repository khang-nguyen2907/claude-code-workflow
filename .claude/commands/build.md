---
description: Build the next task — a local CPU task, or deliver a GPU run (script + run-guide + pre-registered pass/fail). Judging returned results is the master's job, not this one.
argument-hint: "[task-id | deliver]"
disable-model-invocation: true
---

Invoke the `incremental-implementation` skill and follow it. It carries the dispatch, the modes, the
review step, the report format and the completion checklist — **do not re-derive any of them here.**

Echo the mode in one line before acting.

Results are not a `/build` mode: if a finished run's numbers are pasted in, say that judging them is
the master's job and stop.
