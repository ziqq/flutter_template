# Workspace Automation

`mise.toml` owns tool versions, and `mise.lock` records resolved releases. GNU Make remains the public command surface.
Run `mise install`, then `mise exec -- make get` after cloning. Flutter and Dart commands must use the Mise environment.
The workflow does not inspect or select other Flutter installations.

The pinned Flutter 3.47.7 includes Dart 3.13.5. The application and UI example use AGP 9.4.1, Gradle 9.6.1, and
Kotlin 2.4.21 with Temurin 17.0.20+8 and Java 17 source/bytecode targets. Android SDK and NDK versions remain Flutter defaults.
Legacy Kotlin and Android DSL flags remain enabled while native plugins require them. AGP 9.4 is newer than
[Kotlin's fully supported AGP range](https://kotlinlang.org/docs/gradle-configure-project.html); validate debug and
release Android builds when changing this combination or its plugins.

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

GitHub validation runs on pushes and pull requests to `main`. Callers check out the repository before invoking
the setup action, which installs Mise tools, selects Mise's JDK for Flutter, restores a runner-local Pub cache,
and runs `make get` and `make gen`.
Setup keeps the template version at `0.0.1+1`, including tag builds.
Windows setup temporarily uses Mise 2026.8.2 because newer versions have a reported
[cold Flutter installation failure](https://github.com/jdx/mise/issues/14750).
