# Documentation Rules

This file contains rules for comments, API docs, and internal documentation.


## General Rule
- Write `dartdoc`-style comments for public APIs.
- Write docs so a new maintainer can learn how to use the API without reading its implementation first.


## Documentation Philosophy
- Explain **why**, not just **what**.
- Write for the next maintainer.
- Do not restate what is already obvious from the name.
- Keep terminology consistent across the project.
- Prefer usage-oriented documentation over implementation narration.
- Document constraints, ownership, side effects, and failure modes when they are not obvious from the signature.


## Commenting Style
- Use `///` for doc comments.
- Start with a one-sentence summary ending with a period.
- Add a blank line after the summary when the comment continues.
- Avoid redundancy.
- Document either a getter or a setter, not both.
- Do not delete useful existing comments without replacing the lost context.
- Use square-bracket references such as `[Foo]`, `[bar]`, and `[baz]` for in-scope identifiers.
- Prefer prose such as `Returns`, `Throws`, `The [value]...` over `@param` and `@return` tags.
- Put doc comments before annotations.


## Writing Style
- Be brief.
- Avoid unnecessary jargon.
- Use Markdown lightly.
- Use backticks for code spans and fenced blocks for code examples.
- Prefer beginner-friendly wording over team slang, but do not water comments down with obvious detail.
- Use short paragraphs and predictable section starters such as `Returns`, `Throws`, `Use this when`, and `The [parameter]...`.


## What To Document
- Public APIs first.
- Important private APIs when they encode non-obvious constraints.
- Library-level overview comments only for real public entry points or grouped APIs.
- Parameters, return behavior, side effects, and exceptions when they are not obvious.
- Place doc comments before annotations.


## What A Good Doc Comment Must Answer
- What is this API for?
- When should another developer use it instead of a nearby alternative?
- What input, state, or scope assumptions must already be true?
- What does it return, mutate, trigger, cache, navigate to, or persist?
- What can fail, and how should the caller react?
- Is a short usage example needed to make the happy path obvious?


## Flutter And Dart Targets

### Files And Libraries
- Avoid anonymous `library;` directives in ordinary feature files, widgets, screens, controllers, and repositories.
- Add a library-level doc comment only for a real library entry point or grouped public API.
- Prefer documenting the public type, widget, screen, or controller directly instead of adding file-level prose above imports.
- If a file-level comment is justified, explain shared terminology or a public boundary.

### Screens And Public Widgets
- Document what user task the widget or screen supports.
- State which dependencies or scopes must be available for the widget to work.
- Mention the important callbacks, navigation effects, and loading, empty, or error behavior when those are part of the contract.
- Avoid comments such as `Builds the screen.` or `Widget for calendar workload.` because they add no usable guidance.

### Controllers And State Holders
- Document the workflow the controller orchestrates and which layer owns lifecycle wiring.
- Call out sequencing, caching, retry, or concurrency behavior when the caller must understand it to use the controller correctly.
- Document state invariants and any required initial data when those are not obvious from the constructor.

### Repositories And Data Sources
- Document what data the repository provides or mutates, from where, and with what transport or persistence expectations when relevant.
- Mention notable filtering, pagination, cache, or merge semantics.
- Document typed failures, `FormatException` conditions, and caller obligations when they are part of the contract.

### Models, Enums, And Value Types
- Document the meaning of the model in domain language, not just that it is a model.
- For fields and getters, document units, ranges, nullability meaning, and sentinel values when needed.
- For enums, explain what each value represents in business terms if the naming alone is not enough.

### Methods And Helpers
- For side-effect methods, start with what the method does for the caller.
- For value-returning methods, document the result as a value the caller receives.
- Explain non-obvious preconditions, ordering, and performance costs only when they matter to usage.


## Examples And Templates
- Add a code example when the correct usage order is not obvious from the signature.
- Prefer one short happy-path example over long narrative text.
- Use this shape for most public APIs:

```dart
/// One-sentence summary.
///
/// Use this when ...
///
/// The [foo] must ...
///
/// Returns ...
///
/// Throws a [StateError] when ...
///
/// ```dart
/// final result = api.call(foo);
/// ```
```


## Avoid
- Line-by-line comments that merely translate Dart into English.
- Comments that repeat the declaration name or type without adding usage context.
- Internal implementation history that belongs in Git history or issue discussion.
- Large comment blocks where a smaller private helper or better naming would remove the need.
- Commenting every private local variable instead of documenting the non-obvious boundary or invariant once.
- File-level doc comments in routine feature files when the real documentation belongs on the public type below.