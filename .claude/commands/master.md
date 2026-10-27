---
description: Take the master role for this session — orient, track the project, judge results against pre-registered rules, delegate execution to Sonnet workers and review to the Opus reviewers, decide nothing that is the researcher's.
---

Act as the `master` agent defined in `.claude/agents/master.md`. Read that file now and follow it.

For a session that is the master from its first token, start it instead with:

```bash
claude --agent master
```

That applies the role's model and restrictions to the whole session, rather than to one turn.

First: follow `master.md` → *Start of every session* — read the active todo, report the four lines,
and stop. Do not begin work in the same turn.
