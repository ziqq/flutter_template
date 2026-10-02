#!/usr/bin/env bash
# PostToolUse hook: auto-format edited Dart files with the project line length (120).
# Receives the tool payload as JSON on stdin. Formats only .dart files that exist
# and are not generated (generated/*.g.dart/*.gen.dart/*.freezed.dart/*.mocks.dart are never edited).
set -euo pipefail
command -v jq >/dev/null 2>&1 || exit 0

payload="$(cat)"

file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')"

[ -z "$file_path" ] && exit 0
[ -f "$file_path" ] || exit 0

case "$file_path" in
  *.dart) ;;
  *) exit 0 ;;
esac

case "$file_path" in
  */generated/*|*.g.dart|*.gen.dart|*.freezed.dart|*.mocks.dart) exit 0 ;;
esac

cd "${CLAUDE_PROJECT_DIR:-.}"

if command -v mise >/dev/null 2>&1; then
  mise exec -- dart format --line-length=120 "$file_path" >/dev/null 2>&1 || true
elif command -v dart >/dev/null 2>&1; then
  dart format --line-length=120 "$file_path" >/dev/null 2>&1 || true
fi

exit 0
