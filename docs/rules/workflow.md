# Workflow Rules

This file contains project workflow, tooling, and maintenance rules.


## Agent Interaction Guidelines
- Assume the reader understands programming concepts but may not know project-specific Dart conventions.
- When code generation or dependency changes are suggested, explain the practical benefit.
- If a request is ambiguous, clarify the intended behavior and target platform.
- Prefer automated formatting and fixes when available.


## Package Management
- Prefer `pub` tooling when available.
- If an external package is needed, choose a stable and actively maintained package.
- Add regular dependencies with `flutter pub add <package>`.
- Add dev dependencies with `flutter pub add dev:<package>`.
- Remove dependencies with `dart pub remove <package>`.
- Use dependency overrides only when there is a concrete compatibility reason.


## Logging
- Never use `print`.
- Use `dart:developer` for structured logs.
- Use `package:l` for controller or flow logging.


## Formatting And Linting
- Use `make` targets as the public entrypoint for local CLI commands and VS Code tasks.
- For workflows covered by `tool/dart/ci.dart`, `make` delegates to `ci.dart` instead of duplicating orchestration logic.
- `tool/dart/ci.dart` detects `fvm` first and falls back to system `dart` / `flutter` / `fluttergen` when `fvm` is unavailable.
- Run `make format` for formatting.
- Run `make analyze` or `make check` for analysis.
- Respect repo line length of **120**.
- When available, use automatic fix tools before manual cleanup.
- Prefer VS Code tasks that call `make`; this keeps toolchain detection in one place and still routes supported workflows through `ci.dart`.
- Non-verbose `ci.dart` workflows show the active step with a realtime elapsed timer on one line.
- Use `VERBOSE=1 make test-unit`, `VERBOSE=1 make test-packages`, or `VERBOSE=1 make test-unit-all` to stream test output immediately. For direct runner usage, pass `--verbose`, for example `fvm dart run tool/dart/ci.dart test-app --verbose`.
- Use `make ci-pretty`, `make gen-pretty`, `make check-pretty`, or `make test-pretty` when you want grouped CI-style progress logs for local runs.


## Code Generation
- If a change affects generated code, run `make gen`.
- Related commands:
  - `make build-runner`
  - `make fluttergen`
  - `make pubspec-generator`