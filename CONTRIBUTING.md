# Contribution guidelines

These guidelines describe how to contribute to `flutter_template_name` (app + `packages/*`):
workflow, branching, commits, code quality, codegen, and PR rules.


## Development process

### 1. Fork the repository

### 2. Create a branch

For each task, create a branch:
- Task branch: `author/github-<task_number||milestone>/<description>`
- Without task: `author/<type>(feat|fix|chore)/<description>`

Examples:
- `ziqq/github-419/refactor-sale-parsing`
- `ziqq/fix/github-888/block-buttons-during-loading`

### 3. Write clean code

- Keep changes small and focused.
- Prefer feature-based structure:
  - `lib/src/feature/<domain>/{controller,data,model,widget}`
  - shared code: `lib/src/common`
- Widgets are for UI; business logic lives in controllers; data access via repositories.

### 4. Run checks locally before committing

This repo uses **FVM** and a **Makefile pipeline**.

Recommended (matches CI locally):
- Full precommit pipeline: `make precommit`

Useful targets:
| Action | Command |
|---|---|
| Install deps | `make get` |
| Codegen | `make gen` (fluttergen + l10n + build_runner + format) |
| Format check | `make format` |
| Analyze | `make analyze` / `make check` |
| Unit tests (app) | `make test-unit` |
| Unit tests (app + packages) | `make test-unit-all` |
| Integration tests | `make test-integration` |

> Tip (macOS): if `make test-unit` fails on `lcov/genhtml`, install: `brew install lcov`

### 5. Commits

Conventional Commits: <https://www.conventionalcommits.org/en/v1.0.0/>
Pattern: `<type>(github-<task_number||milestone>): <description>`

Examples:
- `feat(0.0.1): init project`
- `fix(github-888): block buttons during loading`
- `chore(1.0.0): update changelog`

Guidelines:
- Prefer atomic commits.
- Explain "what/why", not "how".

### 6. Submit a Pull Request
A PR template is automatically added by GitHub and is **mandatory**.
PR title pattern: `<type>(github-<task_number||milestone>): <description>`

If PR fixes a bug, include:
- **Root cause**
- **Solution**

Example:
`fix(github-888): Buttons are not blocked when loading`

> Root cause: No UI reaction to load time.
> Solution: Wrap the screen widget tree in `AbsorbPointer` and toggle it by loading state.

If work is not ready for review, open PR as **Draft** (or mark as **WIP**) and remove the flag when ready.