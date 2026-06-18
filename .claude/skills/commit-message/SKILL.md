---
name: commit-message
description: "Use when: composing or reviewing AppOrOrgName git commit messages, PR titles, Conventional Commit types, github issue scopes, release scopes, or atomic commit wording."
---

# Commit Message

Source: AppOrOrgName-native; derived from `AGENTS.md`, `CLAUDE.md`, and `docs/CONTRIBUTING.md`.

Use this skill when the user asks for a commit message, PR title, or commit-message review. Do not commit changes unless the user explicitly asks.

## Format

Use Conventional Commits:

```text
<type>(github-<number>): <description>
```

Use a release or non-issue scope only when there is no GitHub issue scope:

```text
chore(38.1.1): update changelog
docs(skills): document agent skill authoring
```

## Types

- `feat`: user-visible capability or product behavior.
- `fix`: bug fix, regression fix, incorrect behavior, or reliability issue.
- `refactor`: internal code structure without intended behavior change.
- `docs`: documentation-only changes.
- `test`: test-only changes.
- `chore`: tooling, generated metadata, versioning, maintenance.
- `build` or `ci`: build pipeline, CI, or dependency infrastructure when clearly applicable.

Prefer the smallest truthful type. Do not use `feat` for internal cleanup.

## Subject Rules

- Write in English.
- Use imperative mood: `fix`, `add`, `document`, `migrate`, `harden`.
- Keep the subject concise and behavior-focused.
- Name the domain when it clarifies the change.
- Avoid low-level implementation noise unless the implementation is the change users maintain.
- Do not end the subject with a period.

Good examples:

```text
fix(github-470): preserve calendar payment filters after refresh
feat(github-459): add sale of goods flow
docs(skills): document AppOrOrgName agent skill policy
refactor(github-420): migrate calendar employee flow to controller
```

Weak examples:

```text
fix: stuff
feat: update files
chore(github-123): changes
docs: markdown edits.
```

## Body And Footer

Add a body only when the subject cannot carry the important context:

- migration notes,
- behavioral risk,
- validation summary,
- generated-code or localization note,
- breaking or release-impacting detail.

Use a footer for issue closing only when appropriate:

```text
Closes #470
```

## PR Title

PR titles should follow the same pattern as commits:

```text
<type>(github-<number>): <description>
```

If a PR spans several commits, title it after the user-visible or domain-level result, not the largest internal refactor.

## Related

- [`verify-changes`](../verify-changes/SKILL.md)
- [`bump-version`](../bump-version/SKILL.md)
- [`docs/CONTRIBUTING.md`](../../../docs/CONTRIBUTING.md)
- [`AGENTS.md`](../../../AGENTS.md)
