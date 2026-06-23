# AppOrOrgName — Agent Instructions

Mobile Flutter application **AppOrOrgName** — CRM / business tool for the any industry.
Monorepo: Flutter client (`lib/`) + local packages (`packages/`).

Published on `App Store`, `Google Play`, `RuStore`, and `AppGallery`.


## Environment setup

- **Flutter version**: managed via [FVM](https://fvm.app/). Always prefix Flutter/Dart commands with `fvm`.
- **Dart SDK**: `>=3.12.0`, Flutter `>3.44.0`.
- **Line length**: `120` (enforced by `make format`).
- **Monorepo workspaces**: root `pubspec.yaml` declares `workspace:` with all packages.

```sh
fvm flutter pub get
fvm flutter run --flavor dev --dart-define-from-file=config/development.json
```


## Monorepo structure

Full project tree: see `README.md` → **Project Structure**.

Key concept: `lib/src/feature/<domain>/` — each domain has `controller/`, `data/`, `model/`, `widget/`.

Packages: `packages/` — shared packages (UI, localization, etc.) are declared in root `pubspec.yaml` workspace.


### Key features (domains)

your_feature/ — e.g. `auth/`, `profile/`, `settings/`, `dashboard/`, etc.
- `controller/` — state management (controllers, notifiers, etc.)
- `data/` — repositories, data sources, API clients, models, mappers
- `model/` — pure data models, enums, extensions
- `widget/` — UI components, screens, dialogs, etc.


## Build, test, and validate

Use `make` targets as the public entrypoint for local CLI commands and VS Code tasks.
Where a workflow is implemented in `tool/dart/ci.dart`, the Makefile should delegate to `ci.dart` instead of re-implementing orchestration.
`tool/dart/ci.dart` auto-detects `fvm` first and falls back to system `dart` / `flutter` / `fluttergen` when `fvm` is unavailable.
Always run `make get` first if dependencies might be stale.

| Action | Command |
|---|---|
| Install dependencies | `make get` |
| Code generation (assets + l10n + build_runner + format) | `make gen` |
| Format | `make format` |
| Analyze (app + packages) | `make check` |
| Unit tests (app) | `make test-unit` |
| Unit tests (app + all packages) | `make test-unit-all` |
| Integration tests | `make test-integration` |
| Full CI pipeline (gen + format + analyze + test) | `make precommit` |


### Test structure

- App tests entry points: `test/unit_test.dart`, `test/widget_test.dart`.
- Each package has its own `test/unit_test.dart` and `test/widget_test.dart`.
- Tests are tagged by layer: `controller`, `data`, `model`, `widget`.
- Run a specific feature tag: `fvm flutter test --tags="<feature>" test/unit_test.dart test/widget_test.dart`.
- Prefer fakes/stubs over mocks. Fake repositories: `FooRepository$Fake` with `@visibleForTesting`.


### Code generation

After changing files that affect generated code, always run:

```sh
make gen
```

This runs: `fluttergen` (assets) → `l10n` (intl) → `build_runner` → `dart format`.

build_runner alone: `make build-runner`


## Key conventions

### Do not edit

- `packages/localization/**` — all generated from Google Sheets (see `docs/localization.md`).
- `**/generated/**`, `*.g.dart`, `*.gen.dart`, `*.freezed.dart`, `*.mocks.dart`.
- Vendor/platform: `build/`, `android/.gradle/`, `ios/Pods/`, `.dart_tool/`.

### Coding rules

- **No `print()`** — use `dart:developer` (`dev.log`) or `package:l` (`l.i`, `l.e`).
- **No `dynamic`** in JSON parsing — pattern matching + `switch`. Errors → `FormatException`.
- **Repositories**: interface `IFooRepository` (abstract interface class) + implementation `FooRepository` + fake `FooRepository$Fake` (`@visibleForTesting`).
- **Controllers**: extend `AppController$Sequential<TState>` with sealed states: `idle` / `processing` / `failed`.
- **Enums**: parse via `fromValue` with explicit `switch`, never use `name` or `values.byName`.
- **Scope pattern**: `InheritedModel` + aspects for DI into widget tree. One scope per feature. Static helpers with `{bool listen = true}`.
- **Immutability**: models are immutable, use `copyWith`, `const` constructors where possible.
- **Dart format**: line length 120, enforced via `make format`.

### Branching and commits

- Branch: `author/github-<number>/<description>` or `author/<type>/<description>`.
- Commits: Conventional Commits — `<type>(github-<number>): <description>`.
- PR title: same pattern. Always run `make precommit` before submitting.


## Documentation reference

Before starting a task, read the relevant doc:

| Topic | File |
|---|---|
| Product goals and priorities | `docs/goals.md` |
| Milestones and acceptance criteria | `docs/milestones.md` |
| Architectural memory and long-term decisions | `docs/decisions.md` |
| Project structure, getting started | `README.md` |
| API package architecture and ownership boundaries | `packages/api/README.md`, `packages/api/docs/architecture.md` |
| Architecture, layers, patterns | `docs/architecture.md` |
| Conventions, generation, icons, prohibitions | `docs/conventions.md` |
| Contributing, dev principles, coding rules | `docs/contributing.md` |
| Localization (Google Sheets → generation) | `docs/localization.md` |
| Firebase, Stripe, external APIs | `docs/integrations.md` |
| CI/CD, environments, releases | `docs/deployment.md` |
| Workspace automation plan | `docs/automation.md` |
| Feature memory docs | `docs/features/*.md` |
| Code templates (state, scope, enums, canvas) | `.github/copilot-instructions.md` |
| VS Code tasks (generators, authoritative) | `.vscode/tasks.json` |


## Configuration files

| File | Purpose |
|---|---|
| `pubspec.yaml` | Dependencies, workspace declaration |
| `analysis_options.yaml` | Lint rules (flutter_lints + custom), analyzer excludes |
| `build.yaml` | build_runner config (drift, etc.) |
| `dart_test.yaml` | Test runner config (tags, platforms, reporters) |
| `config/*.json` | Environment-specific dart-defines (dev/staging/prod) |
| `Makefile` | All build/test/gen/format/analyze targets |


## Agent behavior expectations

Before doing anything:
1. **Clarify** everything unclear — ask clarifying questions.
2. **Highlight** weak points, corner cases that were not accounted for.
3. Read the relevant `docs/*.md` for task context.
4. If backend endpoints are needed — check server documentation and its code.


## Critical rules

- Before substantial work, read `CLAUDE.md` and `AGENTS.md` for full conventions
- Before writing code, read `docs/rules/flutter.md`
- Before adding a feature, read `docs/architecture.md`
- Before changing an existing feature, read `docs/features/<FEATURE>.md` if it exists
- Before adding localization keys, read `docs/localization.md`
- Before modifying generated code or icons, read `docs/conventions.md`
- Never edit: `packages/localization/**`, `**/generated/**`, `*.g.dart`, `*.gen.dart`
- When you've made a major change and completed a task, update the patch version in `pubspec.yaml` (e.g. `0.1.0` → `0.1.1`) and add a note to `CHANGELOG.md` with the version, date, and description of the change.


## Before writing code

For trivial fixes (typos, one-line changes, simple renames), skip discussion and just do it.

For anything non-trivial, do NOT start implementation until all open questions are resolved. First:

1. **Challenge the approach** — point out flaws, missed edge cases, and risks. Be direct.
2. **Ask about unknowns** — if anything is ambiguous, ask. Do not guess or assume.
3. **Propose alternatives** — if there is a simpler or more robust way, say so and explain why.
4. **List edge cases** — enumerate what can break.
5. **Wait for confirmation** — do not write code until the user explicitly approves the plan.

Do only what was asked. Do not refactor surrounding code, add comments to code you did not change, or introduce abstractions for hypothetical future needs.


## After writing code

Do not consider a task done until verified:

- `make format` — no formatting issues
- `make check` — no analyzer warnings
- `make test-unit-all` — all tests pass

If tests or analysis fail, fix the issue before reporting completion.
