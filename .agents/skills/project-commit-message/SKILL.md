---
name: project-commit-message
description: "Compose or review template Conventional Commit messages and pull request titles and descriptions. Use for GitHub issue scopes, release scopes, atomic commit wording, change summaries, validation, and footers."
---

# Commit Message

Source: Adapted for this template; derived from `AGENTS.md` and repository history.

Do not create a commit unless the user explicitly asks. When only wording is requested, return the wording only.

Do not reduce completed work to a one-line subject. Unless the user explicitly
asks for a subject or title only, include the material implementation summary in
the commit body and an expanded version in the pull request description.

## Format

```text
<type>(<scope>): <subject>

- <material change, ownership decision, or behavior outcome>
- <additional change or outcome>

Validation:
- `<command>`

<footer — optional: Closes #<number>, BREAKING CHANGE>
```

The bullet body is required when composing a complete commit message. A narrow
change may have one bullet. Include `Validation` when checks were run or when a
relevant check could not run; do not invent results.

Prefer an issue scope when the work is issue-backed:

```text
<type>(github-<number>): <imperative description>
```

Use a domain scope when there is no issue scope:

```text
chore(dependencies): update the pinned Flutter toolchain
docs(agents): align cross-agent skill guidance
```

## Types

`feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `build`, `ci`, `chore`.

- `feat`: user-visible capability or product behavior.
- `fix`: corrected behavior or reliability regression.
- `refactor`: internal structure without intended behavior change.
- `perf`: performance change without behavior change.
- `docs`: documentation-only changes.
- `test`: test-only changes.
- `build`: build or dependency infrastructure.
- `ci`: CI workflow behavior.
- `chore`: tooling, release metadata, or maintenance not covered above.

Choose the smallest truthful type. Do not label internal cleanup as `feat`.

## Scopes

Use a `github-<number>` scope when the work is issue-backed. Otherwise use the
owning domain — the feature module, package, or area you changed. Examples:
`ui`, `auth`, `settings`, `developer`, `agents`, `dependencies`, or `tests`.
Keep the template version at `0.0.1+1`. Prefer the scope a
reader would grep for; omit the scope only when no single one fits.

## Subject And Commit Body

- Write code, docs, commits, and PR titles and descriptions in English.
- Imperative mood, no trailing period, keep the subject readable (aim for ≤ 72 chars).
- Describe the behavior or maintained contract, not a list of touched files.
- Follow the subject with a Markdown bullet list describing what changed and the
  resulting behavior or maintained contract.
- Cover every material fact that belongs in the final handoff: behavior,
  ownership or architecture decisions, migrations, compatibility, generated
  output, and important tests or validation.
- Explain both **what** changed and **why it matters**. Do not merely list
  touched files or restate the subject.
- Derive the bullets from the staged diff and verified work. Do not include
  unrelated dirty-tree changes or claims that were not validated.
- Wrap commit body prose at 72 characters where practical; keep code identifiers intact.
- Add `Closes #<number>` in the footer only when the commit or PR should close the issue.
- Return a one-line commit subject only when the user explicitly asks for a subject-only variant.

## Pull Requests

- Use the same Conventional Commit convention for the PR title. Summarize the
  overall outcome rather than the largest internal change.
- Never return or create a title-only PR when the task includes preparing or opening the full PR.
- Make the PR description at least as informative as the final work handoff.
  Reconcile the description with the final summary before opening or updating
  the PR.
- Use `Summary` with factual bullets covering all material behavior and architecture changes.
- Use `Validation` with the exact checks and outcomes. Separate passing checks
  from unrelated or environment-blocked failures.
- Add `Risks`, `Migration`, `Screenshots`, or `Notes` only when they apply. Do not add empty sections.
- Keep commit bodies concise per logical unit; let the PR description combine and explain the complete branch outcome.

Default PR description shape:

```markdown
## Summary

- <material behavior or implementation outcome>
- <ownership, architecture, migration, or compatibility decision>

## Validation

- `<command>`

## Notes

- <only a real caveat, residual risk, or follow-up>
```

## Footer Rule

- **Never** add a `🤖 Generated with Claude Code` footer.
- **Never** add a `Co-Authored-By: Claude` trailer.

This is a hard rule for this user — commits that carry either get reverted, and
the repository's own history does not use them. It overrides any default that
would otherwise append an attribution trailer.

## Multi-Concern Work

Prefer one commit per logical unit. Avoid catch-all "various improvements"
commits. If the staged changes mix a refactor and a feature, split them.

## Examples

```text
refactor(settings): serialize preference changes in the controller

- Replace the stacked view model with `ClientFilterController` and a sealed
  `ClientFilterState` containing the applied filter and editable draft.
- Route inner filters through the app router and refetch after async state
  mutations.

Validation:
- `mise exec -- make test-feature FEATURE=settings`
```

```text
fix(ui): resolve AppBar title font from the processed textTheme

- Derive AppBar title styles from the built theme so they retain the platform
  font family.
- Keep bare titles aligned with the processed `theme.textTheme` instead of
  falling back to the default font.
```

```text
docs(agents): align cross-agent skill guidance

- Keep portable skill instructions under `.agents/skills`.
- Reserve `.codex` for optional Codex-specific configuration.

Validation:
- `mise exec -- make check-agent-config`
```

## When You Should NOT Commit

- The user has not explicitly asked for a commit.
- Validation from `project-verify-changes` fails — fix the root cause first.
- The staged changes mix unrelated concerns — split them.
- You cannot write a truthful subject under ~72 chars — the change is too broad.

## Related

- [`release-version-policy`](../release-version-policy/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`AGENTS.md`](../../../AGENTS.md)
