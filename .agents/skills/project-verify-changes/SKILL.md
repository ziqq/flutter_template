---
name: project-verify-changes
description: "Select and run validation for template Flutter, Dart, documentation, generated-code, package, test, CI, and agent-configuration changes. Use after edits or before submission to choose focused checks and the correct escalation path."
---

# Verify Changes

Source: Adapted for this template; derived from `AGENTS.md`, `Makefile`, `mise.toml`, `.vscode/tasks.json`, and workflow/testing rules.

Prefer `mise exec -- make` recipes. Use direct `mise exec -- flutter` or `mise exec -- dart` commands only when no suitable recipe exists.

## Commands

| Purpose | Command |
|---|---|
| Agent configuration | `mise exec -- make check-agent-config` |
| Dependencies | `mise exec -- make get` |
| Generation | `mise exec -- make gen` |
| Formatting | `mise exec -- make format` |
| Analysis | `mise exec -- make check` |
| App tests | `mise exec -- make test-unit` |
| App and package tests | `mise exec -- make test-unit-all` |
| Integration tests | `mise exec -- make test-integration DEVICE=<device-id>` |
| Full pre-submit | `mise exec -- make precommit` |

## Decision Path

1. Run `mise exec -- make get` when dependencies, package exports, or generated inputs may be stale.
2. Run `mise exec -- make gen` when annotations, models, routers, databases, assets, localization inputs, or generated exports changed.
3. Run `mise exec -- make format` for Dart edits.
4. Run `mise exec -- make check` for app, package, tooling, analysis, or agent-configuration changes.
5. Run the smallest focused test that covers changed behavior.
6. Escalate to `mise exec -- make test-unit-all` for shared packages, shared test infrastructure, or cross-feature behavior.
7. Add integration tests for launch, navigation, permissions, platform integration, or end-to-end flows when practical.
8. Run `mise exec -- make precommit` before PR submission, release work, or broad architectural changes.

For one feature, prefer:

```sh
mise exec -- make test-feature FEATURE=<feature>
```

## Special Cases

- Documentation or skill-only changes: run `mise exec -- make check-agent-config`; skip Flutter tests unless commands or executable examples changed.
- Generated code: generate it through `mise exec -- make gen`; never edit generated output manually.
- Known flaky or unavailable checks: report what did not run, why, and the residual risk.

## Reporting

Report commands run, failures, skipped checks with reasons, and remaining risk. Never imply that unrun checks passed.

## Related

- [`project-pr-review`](../project-pr-review/SKILL.md)
- [`docs/rules/workflow.md`](../../../docs/rules/workflow.md)
- [`docs/rules/testing-preferences.md`](../../../docs/rules/testing-preferences.md)
- [`AGENTS.md`](../../../AGENTS.md)
