---
name: verify-changes
description: "Use when: choosing validation commands after AppOrOrgName Flutter, Dart, docs, generated-code, package, test, or configuration changes."
---

# Verify Changes

Source: AppOrOrgName-native; derived from `AGENTS.md`, `CLAUDE.md`, `Makefile`, `.vscode/tasks.json`, `docs/rules/workflow.md`, and `docs/rules/testing-preferences.md`.

Use this skill to choose the smallest validation path that can catch the likely failure introduced by a change. Prefer focused checks first, then escalate when the blast radius crosses feature, package, generated-code, or workflow boundaries.

## Baseline Commands

All Flutter and Dart commands use FVM in this repository. Prefer `make` targets when they exist.

| Purpose | Command |
|---|---|
| Dependencies | `make get` |
| Code generation | `make gen` |
| Format | `make format` |
| Analyze app and packages | `make check` |
| App unit/widget tests | `make test-unit` |
| App and package tests | `make test-unit-all` |
| Integration tests | `make test-integration` |
| Full pre-submit | `make precommit` |

## Decision Tree

1. If dependencies, generated sources, localization, assets, build_runner inputs, or package exports may be stale, run `make get` before other checks.
2. If code generation may be affected, run `make gen` before formatting, analysis, or tests.
3. If Dart files changed, run `make format` unless a narrower formatting command is already part of the task.
4. If app code, package code, analysis options, or generated APIs changed, run `make check`.
5. If domain logic, repositories, controllers, models, parsing, or shared package behavior changed, run focused tests first, then escalate to `make test-unit-all` when package boundaries or shared behavior are involved.
6. If user flows, app launch, platform integration, permissions, routing, or end-to-end behavior changed, include `make test-integration` when practical.
7. If the task is release-like or touches broad architecture, prefer `make precommit` after focused checks pass.

## Focused Test Selection

- For one feature, prefer feature-tagged tests when available: `fvm flutter test --tags="<feature>" test/unit_test.dart test/widget_test.dart`.
- For widget tests, use the project harness from `WidgetTestUtil` instead of ad-hoc app wrappers.
- For local packages, run that package's own tests before the full suite when the impact is isolated.
- For known flaky or slow areas, record what was not run and why instead of pretending coverage exists.

## Generated-Code Triggers

Run or recommend `make gen` when changing:

- Files used by build_runner annotations or generated model/router/database code.
- Assets, icons, or pubspec declarations that feed generated constants.
- Localization inputs or commands.
- API/model shapes that generated code depends on.
- Package exports that generated code imports.

Never edit `packages/localization/**`, `**/generated/**`, `*.g.dart`, `*.gen.dart`, `*.freezed.dart`, or other generated outputs by hand.

## Documentation-Only Changes

For docs-only edits, do not run Flutter tests by default. Validate by reading the changed Markdown and checking editor diagnostics. Run code checks only when docs include executable snippets, command changes, or generated configuration examples that affect the repository workflow.

## Reporting

When reporting verification, state:

- Commands run.
- Commands not run and why.
- Any failures, including whether they appear related to the current change.
- Remaining risk if only focused checks were run.

## Related

- [`review-pr`](../review-pr/SKILL.md)
- [`ui-design-system`](../ui-design-system/SKILL.md)
- [`docs/rules/workflow.md`](../../../docs/rules/workflow.md)
- [`docs/rules/testing-preferences.md`](../../../docs/rules/testing-preferences.md)
- [`AGENTS.md`](../../../AGENTS.md)
