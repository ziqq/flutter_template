---
name: code-documentation
description: "Use when: adding, updating, or reviewing Dart and Flutter documentation comments for public APIs, widgets, controllers, repositories, screens, or library files so usage is clear to maintainers and new contributors."
---

# Code Documentation

Source: AppOrOrgName-native; adapted from `docs/rules/documentation.md`, Dart documentation guidance, Flutter API documentation patterns, and existing AppOrOrgName architecture rules.

Use this skill when code needs documentation comments that teach another developer how to use the API. Write docs that explain purpose, constraints, and correct usage without forcing the reader into the implementation.

## First Sources To Inspect

- `docs/rules/documentation.md` for repository writing rules.
- `docs/rules/flutter.md` for widget, controller, and state-management expectations.
- `docs/rules/architecture.md` for layer boundaries.
- `docs/features/<feature>.md` when documenting feature-specific behavior or terminology.
- Nearby declarations in the same feature or package to keep wording and level of detail consistent.

## Core Standard

- Use `///` doc comments for types, public members, and important private APIs with non-obvious constraints.
- Start with one sentence that tells the reader what this API is for.
- If more detail is needed, add a blank line and then explain usage, constraints, state assumptions, side effects, and failures.
- Prefer user-facing and caller-facing language: explain what another developer can do with this API and what they must provide.
- Use square-bracket links such as `[FooRepository]`, `[load]`, `[context]`, and `[VisitStatus.confirmed]` for in-scope references.
- Use fenced code blocks for short examples when call order or setup is not obvious.

## What To Explain

Every worthwhile doc comment should help the reader answer at least some of these:

- What problem does this type, method, or file solve?
- When should it be used?
- What dependencies, scope objects, or state assumptions must already exist?
- What does it return, change, dispatch, cache, or navigate to?
- What can fail, and what should the caller do next?
- Is there a simpler nearby API the reader might confuse it with?

If the declaration name and signature already answer all of that, do not pad the docs.

## By Declaration Type

### Library Or File Comments
- Avoid file-level doc comments in routine feature files.
- Do not add anonymous `library;` directives just to attach prose above imports.
- Add a file-level overview only for a real public entry point, grouped public API, or terminology-heavy boundary.
- In normal widget, screen, controller, repository, and model files, document the public type directly instead.

### Screens And Widgets
- Explain the user task or UI responsibility.
- Document required scopes, controllers, models, or callbacks.
- Mention important navigation or side effects if a caller embedding the widget must know about them.
- For reusable widgets, document configuration that materially changes behavior or visuals.
- Avoid empty summaries such as `Screen for X` unless the next paragraph explains how it is meant to be used.

### Controllers
- Explain the workflow or sequence the controller owns.
- Document whether methods update state, trigger network work, merge cached data, or invoke callbacks.
- Mention ordering and concurrency expectations if callers must not overlap operations or must preserve previous state.
- Keep `BuildContext` concerns in widgets and scopes, not in controller docs, unless the controller contract explicitly interacts with context-free callbacks.

### Repositories
- Explain the data boundary: what data the repository reads or writes and from where.
- Document cache, pagination, filtering, retry, serialization, or persistence semantics when they affect correct usage.
- Mention typed exceptions and parsing failures when they are part of the contract.

### Models And Enums
- Describe the domain meaning of the type.
- Clarify units, ranges, nullability meaning, and important derived getters.
- For enums, explain the business meaning of values when names alone are not enough.

### Methods, Getters, And Helpers
- For side-effect methods, start with a third-person verb phrase such as `Loads`, `Saves`, `Starts`, or `Resets`.
- For value-returning members, describe the value returned, not the work performed internally.
- For booleans, start with `Whether`.
- Document preconditions, postconditions, and exceptions only when they matter to the caller.

## Writing For New Contributors

- Assume the reader knows Dart and Flutter basics but does not know this feature's domain language or hidden constraints.
- Prefer concrete phrases such as `Use this when the calendar is already scoped with [CalendarScope]` over vague phrases such as `Initializes dependencies`.
- Name the visible outcome: `Returns the grouped workload for the selected day` is better than `Processes the workload data`.
- Show the happy path before edge cases.
- Keep examples short enough to scan quickly.

## Anti-Patterns

- Repeating the declaration in English without new information.
- Describing implementation steps instead of usage.
- Writing novel-length comments for APIs that need a better name or smaller surface.
- Commenting obvious private locals while leaving public contracts undocumented.
- Using JavaDoc tags such as `@param` and `@return` instead of Dart prose.
- Documenting what a widget draws while skipping how a caller should configure or embed it.
- Adding top-of-file prose plus `library;` to ordinary feature files.

## Suggested Shapes

### Public Method

```dart
/// Loads the current employee workload for the selected date.
///
/// Use this when the screen already has a resolved employee and should refresh
/// its visible workload after a date change.
///
/// The [date] is interpreted in the current calendar timezone.
///
/// Returns grouped workload items ordered by start time.
///
/// Throws a [StateError] if no employee is selected.
```

### Public Widget

```dart
/// A workload screen for one employee on a single selected day.
///
/// This screen expects [CalendarScope] and [CalendarWorkloadController] to be
/// available above it in the widget tree.
///
/// Use [onVisitTap] to react to visit selection without forking the screen.
```

### Repository

```dart
/// A repository that loads employee workload snapshots from the calendar API.
///
/// Returns server data merged with locally cached placeholders when offline
/// fallback is available.
///
/// Throws a [FormatException] when the backend response shape does not match
/// the expected JSON object contract.
```

## Review Checklist

- Does the first sentence tell the reader why this declaration exists?
- Can a new maintainer tell how to call or embed it correctly?
- Are required scopes, dependencies, and state assumptions documented?
- Are side effects, return semantics, and failure modes clear where needed?
- Would a short example remove ambiguity faster than another paragraph?
- Did the docs avoid restating obvious information from the signature?

## Related

- [`docs-maintenance`](../docs-maintenance/SKILL.md)
- [`flutter-feature-module`](../flutter-feature-module/SKILL.md)
- [`ui-design-system`](../ui-design-system/SKILL.md)
- [`review-pr`](../review-pr/SKILL.md)
- [`docs/rules/documentation.md`](../../../docs/rules/documentation.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
- [`docs/rules/architecture.md`](../../../docs/rules/architecture.md)