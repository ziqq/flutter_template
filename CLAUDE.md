# AppOrOrgName

Small description of the project, its purpose, and any relevant context. This section should provide a high-level overview of what the project is about and why it exists.


## Structure

- `lib/` — Flutter app (Dart, Mise)
- `lib/src/common/` — Shared: constants, controller, database (drift), models, Navigator-based router, utils, widgets
- `lib/src/feature/<domain>/` — Features: `controller/`, `data/`, `model/`, `widget/`
- `lib/src/common/localization/` — Local ARB sources and generated application localization
- `packages/ui/` — UI kit: widgets, fonts, icons, theme (ThemeExtension)
- `config/` — Environment configs (dev / staging / prod)
- `docs/` — Detailed documentation

## Documentation

- Project structure, getting started: `README.md`
- Full agent conventions and rules: `AGENTS.md`
- Architecture, layers, patterns: `docs/architecture.md`
- Conventions, generation, icons, prohibitions: `docs/conventions.md`
- Localization (ARB → generation): `docs/localization.md`
- Workspace automation plan: `docs/automation.md`
- Feature memory docs: `docs/features/*.md`

## Key Commands

```bash
# Setup
mise exec -- make get                    # Install dependencies
mise exec -- flutter run --flavor dev --dart-define-from-file=config/development.json

# Build & validate
make ci                                # Full CI pipeline (gen + format + analyze + test)
make gen                               # Code generation (l10n + pubspec + build_runner/assets + format)
make format                            # Format (line length 120)
make check                             # Analyze app + packages
make test-unit                         # Unit tests (app)
make test-unit-all                     # Unit tests (app + all packages)
make test-integration                  # Integration tests
```

## Conventions

- **Communication**: Russian with the user. English for all code, comments, docs, and commits
- **Commits**: Conventional commits (feat, fix, refactor, docs, chore)
- **Flutter version**: managed via Mise. Run commands with `mise exec -- make <target>`
- **Dart format**: line length **120**, enforced by `make format`
- **No `print()`** — use `dart:developer` (`dev.log`) or `package:l`
- **No `dynamic`** in any code — prefer explicit types or `Object`
- **No `dynamic`** in JSON — pattern matching + `switch`, errors → `FormatException`

## Critical Rules

- Before substantial work, read `CLAUDE.md` and `AGENTS.md` for full conventions
- Before writing code, read `docs/rules/flutter.md`
- Before adding a feature, read `docs/architecture.md`
- Before changing an existing feature, read `docs/features/<FEATURE>.md` if it exists
- Before adding localization keys, read `docs/localization.md`
- Before modifying generated code or icons, read `docs/conventions.md`
- Never edit: `**/generated/**`, `*.g.dart`, `*.gen.dart`
- This repository is a template: keep `pubspec.yaml` at `0.0.1+1`. Do not bump its version or build number for completed tasks. Record relevant changes under `Unreleased` in `CHANGELOG.md`.

## Before Writing Code

For trivial fixes (typos, one-line changes, simple renames), skip discussion and just do it.

For anything non-trivial, do NOT start implementation until all open questions are resolved. First:

1. **Challenge the approach** — point out flaws, missed edge cases, and risks. Be direct.
2. **Ask about unknowns** — if anything is ambiguous, ask. Do not guess or assume.
3. **Propose alternatives** — if there is a simpler or more robust way, say so and explain why.
4. **List edge cases** — enumerate what can break.
5. **Wait for confirmation** — do not write code until the user explicitly approves the plan.

Do only what was asked. Do not refactor surrounding code, add comments to code you did not change, or introduce abstractions for hypothetical future needs.

## After Writing Code

Do not consider a task done until verified:

- `make format` — no formatting issues
- `make check` — no analyzer warnings
- `make test-unit-all` — all tests pass

If tests or analysis fail, fix the issue before reporting completion.


## Portable agent configuration

- Skills: [.agents/README.md](.agents/README.md); authoring: [docs/agent-skill-authoring.md](docs/agent-skill-authoring.md).
- Agent adapters and hooks: [docs/agent-configuration.md](docs/agent-configuration.md).
- Run `mise exec -- make check-agent-config` after changing agent guidance. `make check` and `make precommit` include it.
