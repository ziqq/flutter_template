---
name: flutter-architecture-policy
description: "Apply template's opinionated Flutter architecture policy when reviewing dependencies, state managers, Clean Architecture, service locators, feature layers, or proposed abstractions."
---

# Flutter Architecture Policy

Source: Adapted for this template; see the [architecture policy](../../../docs/rules/architecture.md) and [Flutter patterns](../../../docs/rules/flutter-patterns.md#1-feature-first-structure).

## Trigger

Use when new Flutter architecture, a state-management package, dependency injection, Clean Architecture, MVVM, GetX, GetIt, Hive, or a broad refactor is proposed or reviewed.

## Default Policy For New Code

- Never introduce `Hive`, `GetIt`, or `GetX`.
- Reject Clean Architecture as the default shape for a modern Flutter feature when it adds ceremonial `domain` layers, interfaces for every class, pass-through use cases, or indirection without a real boundary.
- Prefer explicit constructor dependencies, Flutter/Dart built-ins, feature-oriented folders, and the existing controller/Scope/repository patterns.
- Do not add a state-management package, service locator, generic cache, or abstraction only because a tutorial or template uses it.
- Do not create a global mutable registry to conceal dependencies that can be passed explicitly.

## Context And Exceptions

- These are the project's opinionated defaults, not a license to rewrite legacy code. Do not migrate existing Hive/GetIt/GetX/Clean Architecture code unless the user explicitly asks for migration.
- An exception requires a concrete reason: a mandated external contract, a separately versioned package boundary, multiple real implementations, a platform adapter, or a measured limitation of the built-in solution.
- When an exception is accepted, record the reason, ownership, lifecycle, testing seam, and removal or migration cost.
- If a user explicitly requests a prohibited dependency, comply within that scope but report the trade-offs and do not silently normalize it as the project default.

## Review Output

For every proposed dependency or layer, report:

1. the real problem it solves;
2. the project-native alternative;
3. the added lifecycle, testing, build, and maintenance cost;
4. the evidence for the exception, if one is needed;
5. whether the change is new code, a local compatibility bridge, or an unrequested migration.

## Related

- [`flutter-state-layer-review`](../flutter-state-layer-review/SKILL.md)
- [`flutter-state-management`](../flutter-state-management/SKILL.md)
- [`dart-package-audit`](../dart-package-audit/SKILL.md)
- [`docs/architecture.md`](../../../docs/architecture.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
