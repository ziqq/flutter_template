---
name: project-pr-review
description: "Review template pull requests, diffs, commits, branches, or local changes for regressions, data risks, architecture violations, transport errors, UI/accessibility issues, missing tests, generated-code drift, and stale documentation."
---

# Review Pull Request

Source: Adapted for this template; derived from `AGENTS.md`, `docs/rules/`, feature docs, and repository patterns.

Goal: catch regressions and rule violations before they reach `main`.

Review without editing unless the user separately asks for fixes. Lead with findings ordered by severity; keep the summary secondary. Do not manufacture findings to look thorough — if the diff is small and clean, say so.

## Inputs

- A PR number on `ziqq/flutter_template`, or the current branch diff vs `main`.

## Process

1. Get the diff:
   - `gh pr diff <N>` for a specific PR.
   - `git diff main...HEAD` for the current branch.
   - `git diff` / `git diff --staged` for uncommitted local work.
2. For each touched file, read the relevant canonical rule and feature doc (mapping below) before judging it.
3. Audit against the priorities and the layer checklists.
4. Report findings in the output format below (or comment on the PR with `gh pr review` when the user asks).

## File → Rules Map

- `lib/src/feature/<domain>/**` → [`docs/rules/architecture.md`](../../../docs/rules/architecture.md), [`docs/rules/flutter.md`](../../../docs/rules/flutter.md), and `docs/features/<domain>.md` when it exists.
- `**/model/**`, `*.dart` models → [`docs/rules/models.md`](../../../docs/rules/models.md), [`docs/rules/dart.md`](../../../docs/rules/dart.md).
- `**/data/**` repositories → [`flutter-repository-http-client`](../flutter-repository-http-client/SKILL.md), `docs/architecture.md`, `docs/architecture.md`.
- `**/controller/**` → [`docs/rules/architecture.md`](../../../docs/rules/architecture.md) (sealed states, `AppController$Sequential`).
- `**/widget/**`, `packages/ui/**` → [`flutter-ui-design-system`](../flutter-ui-design-system/SKILL.md), [`docs/rules/ui.md`](../../../docs/rules/ui.md), [`docs/rules/flutter.md`](../../../docs/rules/flutter.md).
- `test/**`, `*_test.dart`, `**/*$Fake*` → [`flutter-widget-tests`](../flutter-widget-tests/SKILL.md), [`docs/rules/testing-preferences.md`](../../../docs/rules/testing-preferences.md).
- `docs/**`, `.agents/**`, `AGENTS.md`, `README.md` → [`project-docs-maintenance`](../project-docs-maintenance/SKILL.md), [`docs/rules/documentation.md`](../../../docs/rules/documentation.md).
- `pubspec.yaml`, `CHANGELOG*.md` → [`release-version-policy`](../release-version-policy/SKILL.md).

## Priorities

1. Data loss, incorrect persistence, auth/session failure, duplicate mutations, broken navigation, stale state, or user-visible regressions.
2. Layering and ownership violations across widgets, controllers, repositories, models, packages, and features.
3. Incorrect `ApiClient$HTTP` vs legacy Dio choice, response-format assumptions, lost typed errors, retries, connectivity, or replay risks.
4. Unsafe parsing, `dynamic`, casts, enum-name serialization, mutable models, or broken identity/copy semantics.
5. UI-kit bypasses, inaccessible controls, overflow, missing loading/empty/error/disabled states, or theme inconsistencies.
6. Missing focused tests, stale fakes/fixtures, unrefreshed generated outputs, analyzer gaps, or undocumented behavioral changes.

## Checklist — Feature / Dart

- [ ] Code stays in the expected `model` / `data` / `controller` / `widget` boundaries; no upward dependencies.
- [ ] No `print()` — logging via `dev.log` or `package:l` (`l.i`, `l.e`).
- [ ] No `dynamic` in JSON parsing; pattern matching + `switch`, errors → `FormatException`.
- [ ] Enums parse via `fromValue` with an explicit `switch`; never `name` or `values.byName`.
- [ ] Models are immutable with `const` constructors and `copyWith`; identity/equality intact.
- [ ] Lines ≤ 120 chars; comments and docs in English.

## Checklist — Data / Transport

- [ ] `ApiClient$HTTP` only for JSON-object, `application/json` endpoints; legacy Dio kept where the raw `Future<Object?>` contract is still needed.
- [ ] Repository trio present and aligned: `IFooRepository` + `FooRepository` + `FooRepository$Fake` (`@visibleForTesting`).
- [ ] Typed API exceptions preserved; no swallowed errors, no assumed response shape.
- [ ] Connectivity, retries, and replay risks considered for mutating calls.

## Checklist — Controller / State

- [ ] Extends `AppController$Sequential<TState>` with sealed `idle` / `processing` / `failed` states.
- [ ] No leaked mutable state; no duplicate in-flight mutations.
- [ ] Scope pattern (`InheritedModel` + aspects) used for DI; one scope per feature.

## Checklist — Widget / UI

- [ ] Reuses `packages/ui` components and theme tokens before local alternatives; no raw hex colors.
- [ ] Loading, empty, error, disabled, and permission states are covered.
- [ ] `Semantics`, focus order, and hit targets are correct; no overflow at small widths.

## Checklist — Tests / Generated / Docs

- [ ] Focused tests exist for changed behavior and carry the right layer tag; fakes/fixtures updated.
- [ ] Reuses the existing `pumpScreen` harness and feature scopes instead of new harnesses.
- [ ] Generated output (`**/generated/**`, `*.g.dart`, `*.gen.dart`, `*.freezed.dart`, `*.mocks.dart`) is regenerated via `mise exec -- make gen`, never hand-edited.
- [ ] Durable behavior changes are reflected in `docs/features/`, `docs/rules/`, package docs, `.agents/`, `AGENTS.md`, or `README.md`.
- [ ] Root `pubspec.yaml` stays at `0.0.1+1`; relevant changes are recorded under `Unreleased`.

## Finding Shape

For each actionable finding include:

- severity;
- exact file and tight line range;
- the behavior that can fail;
- evidence connecting the change to the failure;
- the smallest practical fix direction.

Do not report style preferences unless they hide a correctness, accessibility, or durable maintenance risk.

## Output Format

Group findings by severity, then file. Example:

```
## Blocking
- lib/src/feature/client/data/client_repository.dart:88 — parses response with `as Map`; a non-JSON body throws late. Guard with a typed decode and FormatException.
- lib/src/feature/sale/controller/sale_controller.dart:42 — mutation runs without a sealed `processing` gate; a double tap fires two POSTs.

## Suggestions
- lib/src/feature/client/widget/client_card_screen.dart:60 — missing empty state; a client with no sales renders a blank column.

## Looks good
- Fake repository and fixtures in test/ stay aligned with the new field.
```

If no finding is proven, say so and list remaining verification gaps (unrun checks, untested paths).

## Related

- [`flutter-repository-http-client`](../flutter-repository-http-client/SKILL.md)
- [`flutter-ui-design-system`](../flutter-ui-design-system/SKILL.md)
- [`flutter-widget-tests`](../flutter-widget-tests/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/rules/architecture.md`](../../../docs/rules/architecture.md)
- [`docs/rules/testing-preferences.md`](../../../docs/rules/testing-preferences.md)
- [`AGENTS.md`](../../../AGENTS.md)
