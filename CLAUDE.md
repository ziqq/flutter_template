# Template

Flutter CRM / business tool for the any industry. Monorepo.

## Structure

- `lib/` — Flutter app (Dart, FVM)
- `lib/src/common/` — Shared: constants, controller, database (drift), models, router (auto_route), utils, widgets
- `lib/src/feature/<domain>/` — Features: `controller/`, `data/`, `model/`, `widget/`
- `packages/api/` — Shared transport package (Dio V1/V2 + HTTP middleware client + connectivity + exceptions + response helpers)
- `packages/core/` — Shared models, utilities, validators
- `packages/ui/` — UI kit: widgets, fonts, icons, theme (ThemeExtension)
- `packages/localization/` — Localization (GENERATED from Google Sheets, never edit)
- `config/` — Environment configs (dev / staging / prod)
- `docs/` — Detailed documentation

## Documentation

- Product goals and priorities: `docs/goals.md`
- Milestones and acceptance criteria: `docs/milestones.md`
- Architectural memory and long-term decisions: `docs/decisions.md`
- Project structure, getting started: `README.md`
- API package architecture and ownership boundaries: `packages/api/README.md`, `packages/api/docs/architecture.md`
- Full agent conventions and rules: `AGENTS.md`
- Architecture, layers, patterns: `docs/architecture.md`
- Conventions, generation, icons, prohibitions: `docs/conventions.md`
- Contributing, dev principles, coding rules: `docs/contributing.md`
- Localization (Google Sheets → generation): `docs/localization.md`
- Firebase, Stripe, external APIs: `docs/integrations.md`
- CI/CD, environments, releases: `docs/deployment.md`
- Workspace automation plan: `docs/automation.md`
- Feature memory docs: `docs/features/*.md`

## Key Commands

```bash
# Setup
fvm flutter pub get                    # Install dependencies
fvm flutter run --flavor dev --dart-define-from-file=config/development.json

# Build & validate
make ci                                # Full CI pipeline (gen + format + analyze + test)
make gen                               # Code generation (fluttergen + l10n + build_runner + format)
make format                            # Format (line length 120)
make check                             # Analyze app + packages
make test-unit                         # Unit tests (app)
make test-unit-all                     # Unit tests (app + all packages)
make test-integration                  # Integration tests
```

## Conventions

- **Communication**: Russian with the user. English for all code, comments, docs, and commits
- **Commits**: Conventional commits (feat, fix, refactor, docs, chore)
- **Flutter version**: managed via FVM. Always prefix commands with `fvm`
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
- Never edit: `packages/localization/**`, `**/generated/**`, `*.g.dart`, `*.gen.dart`
- When you've made a major change and completed a task, update the patch version in `pubspec.yaml` (e.g. `0.1.0` → `0.1.1`) and add a note to `CHANGELOG.md` with the version, date, and description of the change.

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

