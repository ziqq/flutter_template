#!/usr/bin/env bash
# Stop hook: remind to validate before considering the task done when source or
# agent configuration has uncommitted changes.
set -euo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}"

# Nothing staged or unstaged -> stay silent.
if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
  exit 0
fi

# Keep portable agent configuration on its deterministic validation path.
agent_changed="$(git status --porcelain 2>/dev/null | grep -E '(^|[[:space:]])(AGENTS\.md|CLAUDE\.md|\.agents/|\.codex/|\.claude/|docs/agent-(configuration|skill-authoring)\.md)' || true)"

if [ -n "$agent_changed" ]; then
  cat <<'MSG'
Reminder: validate agent configuration before finishing:
  mise exec -- make check-agent-config
MSG
fi

# Skip the source reminder for docs-only changes.
source_changed="$(git status --porcelain 2>/dev/null | grep -E '\.(dart|yaml|yml|arb|json)$' || true)"
[ -z "$source_changed" ] && exit 0

cat <<'MSG'
Reminder: select validation through the project-verify-changes skill and AGENTS.md:
  mise exec -- make format # Dart changes
  mise exec -- make check  # app, package, tooling, or configuration changes
  run focused tests, then mise exec -- make test-unit-all for shared or cross-package behavior
MSG

exit 0
