---
description: Validate the branch — format, analyze, and run all unit tests.
---

Use the `project-verify-changes` skill, run the project validation pipeline in order,
and report results concisely.
Stop and surface the failure if any step fails; do not continue to the next step.

1. `mise exec -- make format` — line length 120, no formatting diffs.
2. `mise exec -- make check` — analyzer for app and packages, no warnings.
3. `mise exec -- make test-unit-all` — app and package unit tests must pass.

If everything passes, state that the validation passed; do not claim the Git
working tree is clean unless `git status` proves it. If anything fails, show the
relevant output and fix failures caused by the current change before reporting
done, following `AGENTS.md`.
