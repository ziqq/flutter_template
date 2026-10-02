# Agent Configuration

[AGENTS.md](../AGENTS.md) owns repository policy. [CLAUDE.md](../CLAUDE.md) and
[Copilot instructions](../.github/copilot-instructions.md) are entrypoints to the same policy.

## Portable skills

The 37 skills in [.agents/README.md](../.agents/README.md) are the canonical workflows.
`.claude/skills` is a relative symlink to `../.agents/skills`; do not maintain duplicate copies.
Skills use actual template paths, Make/Mise commands, and local ARB inputs. Product-specific
backend contracts, account switching, Google Sheets localization, and Rust guidance are not imported.

## Codex

[.codex/config.toml](../.codex/config.toml) declares the official schema and the shared agent concurrency limit.
Optional agents live in [.codex/agents](../.codex/agents): `luna_worker` for bounded implementation and
`template_reviewer` for read-only review. Their model and sandbox defaults match the imported roles.
Availability of a role does not authorize delegation. Use only when the user or applicable instructions request it.
Authentication, root model/provider selection, approval policy, and personal settings remain user-owned.
Cloud environments can use the portable skills without loading local Codex configuration.

## Claude Code

[.claude/settings.json](../.claude/settings.json) contains shared read permissions, generated-file and secret
protections, hooks, and a status line. It does not pre-authorize arbitrary shell commands or writes.
Personal permission changes belong in ignored `.claude/settings.local.json`.

- `format-dart.sh` formats edited Dart source, skipping generated files.
- `stop-reminder.sh` reminds about checks when tracked or untracked changes exist; it does not run them.
- `notify.sh` sends a local macOS notification; notification text is passed as data.
- `statusline.sh` shows the workspace, branch, selected `template.flavor` (default `dev`), and model.

Hooks use Bash and `jq`; JSON-dependent hooks skip when `jq` is unavailable. Notifications also require macOS
`osascript`. They must not change repository credentials, global configuration, or publish anything.
Commands in [.claude/commands](../.claude/commands) are thin adapters to skills and Make workflows.
The `bump` command checks the fixed template version; it never increments `0.0.1+1`.

## Validation

Run `mise exec -- make check-agent-config`. It checks skill metadata, names and index entries,
local Markdown link targets, stale source references, custom-agent required fields, Claude JSON, expected hooks,
the compatibility symlink, and the Codex schema declaration. `make check` and `make precommit` include it.
This is a repository consistency check, not a full TOML/schema validator or proof that an agent client reloaded its config.
Validate JSON/TOML parsing and shell syntax separately when changing those formats.
