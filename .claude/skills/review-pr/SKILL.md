---
name: review-pr
description: "Use when: reviewing AppOrOrgName diffs, pull requests, local changes, regressions, missing tests, generated-code drift, UI-kit usage, or documentation drift."
---

# Review Pull Request

Source: AppOrOrgName-native; derived from `AGENTS.md`, `CLAUDE.md`, `docs/rules/**`, feature docs, and existing repository patterns.

Use this skill for code-review mode. Findings come first, ordered by severity. Focus on bugs, regressions, missing validation, and violations of AppOrOrgName conventions. Keep summaries secondary.

## Review Priorities

1. User-visible regressions, data loss, broken navigation, stale UI state, duplicate mutations, auth/session failures, or incorrect persistence.
2. Cross-layer architecture violations: widget logic in repositories, parsing in widgets, controller-to-controller coupling, feature boundary leaks, or hidden global state.
3. Repository and transport risks: wrong `ApiClient$HTTP` / `ApiClient$Dio` choice, non-JSON assumptions, lost metadata, retry/replay issues, connectivity behavior, or unhandled API errors.
4. Model and parsing risks: `dynamic`, unsafe casts, missing `FormatException`, enum parsing through names, mutable models, or copy/identity mistakes.
5. UI risks: bypassing `packages/ui`, inconsistent theme usage, inaccessible controls, insufficient hit targets, missing loading/error/empty states, or layout overflow on supported sizes.
6. Test and validation gaps: no focused tests for changed behavior, stale fakes/fixtures, missing widget harness usage, generated outputs not refreshed, or skipped analyzer concerns.
7. Documentation drift: changed behavior or workflow without updates to `docs/features/**`, `docs/rules/**`, package docs, `README.md`, `AGENTS.md`, or `CLAUDE.md`.

## AppOrOrgName-Specific Checks

- Feature code should stay under `lib/src/feature/<domain>/{controller,data,model,widget}` unless there is a clear shared concern.
- Repositories should expose `I<Name>Repository`, concrete `<Name>Repository`, and deterministic `$Fake` implementations when tests need them.
- Controllers should use `AppController$Sequential<TState>` and sealed idle/processing/failed state patterns for async flows.
- Widgets should compose small immutable widgets and avoid network calls, parsing, or expensive work in `build()`.
- UI should import and reuse `package:ui/ui.dart` components and theme primitives before introducing custom styling.
- Tests should follow existing feature patterns and use `WidgetTestUtil` helpers for widget harnesses.
- Generated and localization files should not be manually edited.

## How To Write Findings

Each finding should include:

- Severity: blocking, high, medium, or low.
- Concrete behavior that can break.
- File and line reference when available.
- Why the current change causes the risk.
- The smallest practical fix direction.

Do not list style preferences unless they hide a real maintainability, correctness, accessibility, or project-consistency risk.

## Review Output Shape

Use this order:

1. Findings, ordered by severity.
2. Open questions or assumptions.
3. Brief change summary only if useful.
4. Verification gaps and residual risk.

If there are no findings, say that clearly and mention any remaining test or validation gap.

## Documentation Drift

When behavior changes, check the likely documentation target:

- Feature behavior: `docs/features/<feature>.md`.
- Architecture or layering: `docs/architecture.md` or `docs/rules/architecture.md`.
- Flutter/UI patterns: `docs/rules/flutter.md` or `docs/rules/ui.md`.
- Testing and validation: `docs/rules/testing-preferences.md` or `docs/rules/workflow.md`.
- Agent workflow: `AGENTS.md`, `CLAUDE.md`, or `.claude/skills/README.md`.

Do not request doc updates for mechanical edits that do not change behavior, workflow, or project knowledge.

## Related

- [`verify-changes`](../verify-changes/SKILL.md)
- [`ui-design-system`](../ui-design-system/SKILL.md)
- [`docs/rules/architecture.md`](../../../docs/rules/architecture.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
- [`docs/rules/testing-preferences.md`](../../../docs/rules/testing-preferences.md)
- [`docs/agent-skill-authoring.md`](../../../docs/agent-skill-authoring.md)
