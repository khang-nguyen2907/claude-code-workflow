#!/usr/bin/env bash
# PreToolUse(Bash): refuse a second concurrent test-gate run, and refuse the full
# smoke suite during an ordinary build.
#
# Prose rules did not stop this: one build launched the same gate three times
# concurrently plus a task whose only job was to wait for it (~50 min wasted).
# Exit code 2 blocks the call and returns stderr to Claude as the reason.

input=$(cat 2>/dev/null) || exit 0
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null) || exit 0

# only inspect commands that look like the gate
case "$cmd" in
  *pytest*|*"mypy src"*) ;;
  *) exit 0 ;;
esac

# 1. a gate is already running -> block
if pgrep -f "pytest tests" >/dev/null 2>&1; then
  echo "A test gate is already running (pgrep matched 'pytest tests'). Do not start a second one, \
and do not create a task to wait for it. Let the running gate finish and read its output." >&2
  exit 2
fi

# 2. the full smoke suite during a build -> block
if printf '%s' "$cmd" | grep -q 'tests/unit[[:space:]]\+tests/smoke\|tests/smoke[[:space:]]*$'; then
  if ! printf '%s' "$cmd" | grep -q 'tests/smoke/[a-z]'; then
    echo "That is the FULL gate (all of tests/smoke, ~25 min: 14 of 25 files train, shard across \
devices, or load real encoders). The build gate is tests/unit plus only the smoke files this change \
touches — see .claude/references/project-profile.md 'The gate'. Run the full gate before a GPU delivery, \
not on an ordinary build." >&2
    exit 2
  fi
fi

exit 0
