# Dart Rules

This file contains language-level rules for Dart code in the project.
Framework-specific guidance for widgets, theming, routing, layout, and canvas
stays in [flutter.md](flutter.md).


## Code Quality
- **Maintainable structure:** Keep UI, business logic, and data access clearly separated.
- **Analyzer source of truth:** Treat [analysis_options.yaml](../../analysis_options.yaml) as the canonical source for analyzer and linter behavior. Write production code and tests to satisfy enabled rules up front, not as a cleanup step after implementation.
- **Naming:** Avoid abbreviations. Prefer explicit, stable, descriptive names for types, methods, fields, and variables.
- **Conciseness:** Keep code short only when readability is preserved.
- **Simplicity:** Prefer straightforward code over clever code.
- **Error handling:** Anticipate failures and make them explicit. Never fail silently.
- **Line length:** Limit lines to **120** characters. This is enforced by `make format`.
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