#!/usr/bin/env bash
# Status line for Claude Code: "<dir> · ⎇ <branch> · <flavor> · <model>".
# Receives a JSON context payload on stdin (model, workspace, ...).
set -euo pipefail
command -v jq >/dev/null 2>&1 || exit 0

payload="$(cat)"

model="$(printf '%s' "$payload" | jq -r '.model.display_name // .model.id // "?"')"
dir="$(printf '%s' "$payload" | jq -r '.workspace.current_dir // .cwd // "."')"

cd "$dir" 2>/dev/null || true

name="$(basename "$dir")"
branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '-')"

# Best-effort flavor guess from the currently selected VS Code launch / last run.
flavor="$(git config --local template.flavor 2>/dev/null || echo 'dev')"

printf '%s · ⎇ %s · %s · %s\n' "$name" "$branch" "$flavor" "$model"
