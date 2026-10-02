# Workspace Automation

`mise.toml` owns tool versions, and `mise.lock` records resolved releases. GNU Make remains the public command surface.
Run `mise install`, then `mise exec -- make get` after cloning. Flutter and Dart commands must use the Mise environment.
The workflow does not inspect or select other Flutter installations.

`Makefile` delegates reusable generation, formatting, analysis, and testing workflows to `tool/dart/ci.dart`.
`tool/scripts/` contains platform-specific commands. VS Code and GitHub Actions call the same Make targets.
Do not duplicate orchestration in CI or add a competing task runner.

- `make gen`: assets, ARB localization, pubspec metadata, build_runner, and formatting.
- `make format` / `make format-check`: application, tooling, UI package, and example sources; generated files are skipped.
- `make check`: static analysis of application and package sources.
- `make test-unit-all`: application tests, package tests, and package example tests.
- `make precommit`: generation, formatting, analysis, and tests.

Use `VERBOSE=1` to stream command output. Platform builds require their native SDKs. Linux and Windows runners must be
built on their respective hosts. iOS release builds additionally require project-specific signing credentials.
