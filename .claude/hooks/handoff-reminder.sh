#!/usr/bin/env bash
# Nudges (never forces) a /handoff write-up once per session, when the session has
# actually changed something and no handoff has been written yet.
#
# Why a nudge and not automation: SessionEnd hooks cannot inject context or make Claude
# act -- "output and exit code are ignored, except terminalSequence" -- so there is no
# end-of-conversation trigger that can author a document. Stop fires at the end of every
# turn and CAN inject context, so this fires there, exactly once, behind a work gate.
#
# Events: SessionStart records a baseline; Stop / PreCompact compare against it.
# Disable: remove the hook entries from .claude/settings.json (or /hooks).
set -uo pipefail

INPUT=$(cat)
EVENT=$(jq -r '.hook_event_name // empty' <<<"$INPUT" 2>/dev/null)
SID=$(jq -r '.session_id // "unknown"' <<<"$INPUT" 2>/dev/null)

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0   # not a repo: stay silent

STATE_DIR="${TMPDIR:-/tmp}/claude-handoff"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0
BASE="$STATE_DIR/${SID}.baseline"
NUDGED="$STATE_DIR/${SID}.nudged"

snapshot() { git rev-parse HEAD 2>/dev/null; git status --porcelain 2>/dev/null; }

if [ "$EVENT" = "SessionStart" ]; then
  snapshot > "$BASE" 2>/dev/null
  rm -f "$NUDGED"
  exit 0
fi

# No baseline means the hook was added mid-session -- say nothing rather than guess.
[ -f "$BASE" ] || exit 0
[ -f "$NUDGED" ] && exit 0

# Gate 1: did this session actually change anything substantial?
CHANGED=$(diff <(snapshot) "$BASE" 2>/dev/null | grep -c '^[<>]')
[ "${CHANGED:-0}" -ge 3 ] || exit 0

# Gate 2: a handoff written since the session began means there is nothing to nudge about.
if find . -type d \( -name .git -o -name node_modules -o -name '.venv*' \) -prune -o \
        -path '*/docs/handoff/*.md' -newer "$BASE" -print 2>/dev/null | grep -q .; then
  exit 0
fi

touch "$NUDGED"

read -r -d '' MSG <<'EOM'
This session has changed several files and no handoff has been written. If the work involved a
lesson worth keeping, a decision, a reversal, a non-obvious finding, a spec/plan, or work left
delivered-but-not-run -- or if the next step will happen in a new chat -- consider running the
`handoff` skill before the conversation ends. It records why (which the diff cannot) and leaves a
"Resume here" block a fresh session can act on. Skip it for routine work.
EOM

jq -n --arg e "$EVENT" --arg m "$MSG" \
  '{hookSpecificOutput: {hookEventName: $e, additionalContext: $m}}'
