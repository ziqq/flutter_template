---
name: project-code-documentation
description: "Write or review caller-focused Dart and Flutter documentation for public APIs, widgets, screens, controllers, repositories, models, enums, helpers, and library entrypoints in template."
---

# Code Documentation

Source: Adapted for this template; adapted from `docs/rules/documentation.md`, Dart documentation guidance, and existing project APIs.

## Inspect First

- Read `docs/rules/documentation.md` and the relevant Dart, Flutter, architecture, model, or feature documentation.
- Inspect nearby declarations for terminology and expected detail.
- Identify the caller, required scopes or dependencies, side effects, failures, and state assumptions.

## Write For Callers

- Start with one sentence explaining the API's purpose.
- Explain when to use it instead of a nearby alternative when that choice is non-obvious.
- Document preconditions, units, ranges, null meaning, ownership, caching, sequencing, navigation, persistence, and failures only when relevant.
- Prefer one short happy-path example when call order or embedding is unclear.
- Use `///`, Markdown sparingly, and square-bracket references for in-scope identifiers.
- Place documentation before annotations.

## By API Type

- Widgets and screens: describe the user task, required scopes, callbacks, navigation, and important loading/empty/error behavior.
- Controllers: describe the workflow, lifecycle owner, sequencing, concurrency, retry, and state invariants.
- Repositories: describe the data source, transport or persistence contract, pagination/cache semantics, and typed failures.
- Models and enums: use domain language; document units, nullability, sentinel values, and serialization meaning.
- Helpers: document side effects, ordering, performance cost, and failures when callers must account for them.
- Libraries: add library-level prose only for real public entrypoints or grouped APIs.

## Avoid

- Restating a declaration in English.
- Narrating implementation history or every local variable.
- Adding anonymous `library;` directives only to attach prose.
- Deleting useful documentation without preserving its caller-facing information.
- Expanding a local comment into architecture documentation that belongs in `docs/`.

## Review Checklist

- Can a maintainer use the API without reading its implementation first?
- Are non-obvious dependencies, side effects, returns, and failures clear?
- Is every sentence useful and consistent with current behavior?
- Does durable behavior also need a project or feature documentation update?

## Related

- [`project-docs-maintenance`](../project-docs-maintenance/SKILL.md)
- [`flutter-feature-module`](../flutter-feature-module/SKILL.md)
- [`docs/rules/documentation.md`](../../../docs/rules/documentation.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
- [`docs/rules/architecture.md`](../../../docs/rules/architecture.md)
