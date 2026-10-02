#!/usr/bin/env bash
# Pass notification text as data, never as AppleScript source.
set -euo pipefail
command -v jq >/dev/null 2>&1 || exit 0
message="$(jq -r '.message // "Claude Code needs your attention"')"
if command -v osascript >/dev/null 2>&1; then
  osascript - "$message" <<'APPLESCRIPT' >/dev/null 2>&1 || true
on run argv
  display notification (item 1 of argv) with title "Claude Code — Flutter template" sound name "Ping"
end run
APPLESCRIPT
fi
