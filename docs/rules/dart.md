# Dart Rules

This file contains language-level rules for Dart code in the project.
Framework-specific guidance for widgets, theming, routing, layout, and canvas
stays in [flutter.md](flutter.md).

Detailed language semantics, async coordination, isolates, Iterable pipelines, extension types, and examples are in
[Dart language rules](dart-language.md).


## Code Quality
- **Maintainable structure:** Keep UI, business logic, and data access clearly separated.
- **Analyzer source of truth:** Treat [analysis_options.yaml](../../analysis_options.yaml) as the canonical source for analyzer and linter behavior. Write production code and tests to satisfy enabled rules up front, not as a cleanup step after implementation.
- **Naming:** Avoid abbreviations. Prefer explicit, stable, descriptive names for types, methods, fields, and variables.
- **Conciseness:** Keep code short only when readability is preserved.
- **Simplicity:** Prefer straightforward code over clever code.
- **Error handling:** Anticipate failures and make them explicit. Never fail silently.
- **Line length:** Limit lines to **120** characters. This is enforced by `mise exec -- make format`.
- **Naming styles:** Use `PascalCase` for types, `camelCase` for members/functions/enums, and `snake_case` for files.
- **Functions:** Keep functions focused and small. A function should usually do one thing.
- **Testability:** Prefer code that can be exercised with fakes or in-memory implementations.
- **Logging:** Use `dart:developer` or `package:l`. Never use `print`.


## Dart Best Practices
- Follow the official Effective Dart guidance where it does not conflict with repo rules.
- When the analyzer reports duplicated receiver usage, prefer cascades for consecutive mutations on the same object when that improves readability. Keep single-call statements non-cascaded to stay aligned with both `cascade_invocations` and `avoid_single_cascade_in_expression_statements`.
- Keep related public and private types in the same library when they form one cohesive unit.
- Group related libraries in the same folder.
- Add documentation comments to public APIs.
- Write comments only for non-obvious decisions or constraints.
- Do not add trailing comments.
- Use `Future`, `async`, and `await` for async work.
- Use `Stream` for event sequences.
- Write sound null-safe code. Avoid `!` unless non-nullability is guaranteed by design.
- Use pattern matching and records when they reduce noise and increase clarity.
- Prefer exhaustive `switch` statements and expressions.
- Use appropriate exceptions. Throw project-specific exceptions only for project-specific failure modes.
- Use arrow syntax for simple one-line functions.


## Async Primitive Selection

Choose the primitive from the contract rather than from the implementation's apparent sophistication.

| Primitive | Use it for | Do not use it as |
|---|---|---|
| `Future` | One result or one completion/failure. | A long-lived event protocol. |
| `Stream` | An ordered sequence of events observed over time. | A hidden mutable state store. |
| `Queue` | Work items owned and drained by one coordinator. | A replacement for a broadcast event stream. |
| `ValueNotifier` / `ChangeNotifier` | Local synchronous state and focused UI rebuilds. | Cross-feature orchestration or a server protocol. |
| `compute` / isolate | CPU-bound work, heavy synchronous parsing/decoding, or a measured UI-isolate bottleneck. | Ordinary asynchronous I/O by itself. |

For isolate work, document the message shape, ownership, startup cost, timeout, cancellation, late-result behavior, and
port cleanup. Never send `BuildContext`, widgets, controllers, platform handles, or mutable feature state across an
isolate boundary. The production `compute` examples in `employees_repository.dart` are the smallest local reference
for typed background deserialization. On Flutter Web, verify the platform-specific isolate semantics before treating the
boundary as a separate UI thread.


## Resource Lifecycle And Async Cleanup

Every acquired resource must have one owner, one matching cleanup action, and a documented failure window.

- Acquire resources in a visible order and clean them up in reverse dependency order.
- Clean up only resources that were successfully acquired.
- Make cleanup idempotent across success, error, cancellation, and owner disposal.
- Check cancellation between awaited initialization steps and connect cancellation before entering a long-lived stream,
  socket, timer, or platform-listener phase.
- Keep rollback cleanup separate from commit cleanup. A committed transaction must disable or replace its rollback path.
- When several cleanup actions run after one failure, preserve the original operation error and report cleanup failures
  separately so one failing cleanup cannot hide the root cause.
- Treat `Future.wait` as coordination for parallel work, not as a rollback mechanism. Parallel acquisition needs explicit
  tracking of resources that may finish after a sibling has failed.

Use `docs/features/initialization.md` and `AppMigrator` tests as the project reference for idempotent startup migration,
failure preservation, and storage ownership. Do not copy commented experimental isolate code as a production pattern.
