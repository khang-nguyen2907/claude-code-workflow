---
name: dispatching-parallel-agents
description: Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies
---

# Dispatching Parallel Agents

Give each independent problem domain its own agent with isolated context, and run them concurrently. Agents never inherit your session history: write exactly what each needs. This also keeps your own context free for coordination.

## When to use

All must hold:
- 2+ problems (e.g. 3+ test files failing for different root causes, or several subsystems broken independently)
- Each can be understood without context from the others
- No shared state: agents will not edit the same files or use the same resources

## When NOT to use

- Failures are related (fixing one may fix others): investigate together first
- You need the full system state, or you don't yet know what is broken (exploratory debugging)
- Agents would interfere with each other (same files or resources)
- **Two different levers or judged tasks.** That is bundling, not parallelism. A research build judges one change per run, so parallel work must converge into one task's one gate run, never two judged results.

## Pattern

1. **Group by what is broken.** One agent per domain (e.g. tool approval flow, batch completion, abort handling).
2. **Write one focused prompt per agent** (below).
3. **Dispatch all agents in the same response.** Multiple dispatch calls in one response run in parallel; one per response runs sequentially.
4. **Verify after they return:** read each summary, check for conflicts (did two agents touch the same code?), run the full suite, spot-check for systematic errors, then integrate.

## Agent prompt must contain

- **Specific scope:** one test file or subsystem, not "fix all the tests"
- **Context:** paste the error messages and test names
- **Goal:** what must pass or work
- **Constraints:** e.g. "fix tests only", "do NOT change production code", "do NOT just raise timeouts, find the real cause"
- **Expected output:** e.g. "return root cause and a summary of changes"

Example:

```markdown
Fix the 3 failing tests in src/agents/agent-tool-abort.test.ts:
1. "should abort tool with partial output capture": expects 'interrupted at' in message
2. "should handle mixed completed and aborted tools": fast tool aborted instead of completed
3. "should properly track pendingToolCount": expects 3 results, gets 0

These look like timing/race issues. Read the file, find the root cause (timing or real bug),
replace arbitrary timeouts with event-based waiting, fix abort bugs if found, adjust test
expectations only if the tested behavior legitimately changed. Do NOT just increase timeouts.
Return: root cause and what you changed.
```

## In this workspace

Two legitimate uses:
1. Independent bug or test investigations (pattern above).
2. Contract-bound pieces of **one** lever during a build (`incremental-implementation`, *Contract-first slicing*). Pin the interface (shapes, dtypes, masking convention, label format) **before** dispatching either side, so neither agent guesses the other's shape.

```text
Agent 1 (general-purpose): "Build the encoder against this contract: emits [B, L, D], mask is
  1=keep/0=pad, both built from the tokenizer's offsets. Write src/model/encoder.py and its unit
  test, asserting that exact shape and mask dtype. Do not import or assume anything about the
  consumer. Return: the diff and which assertion the test makes."

Agent 2 (general-purpose): "Build the fusion module against the same contract, using a fixture
  that matches it. Do not import the real encoder. Write src/model/fusion.py and its unit test.
  Return: the diff and which assertion the test makes."
```

Both pieces land in one commit, one gate run, one todo task. Parallelism is in the building, never in what gets judged.
