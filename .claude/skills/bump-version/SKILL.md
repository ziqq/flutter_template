---
name: bump-version
description: "Use when: deciding whether to bump AppOrOrgName app version, update pubspec.yaml, write CHANGELOG.md entries, or avoid version churn for docs-only and trivial changes."
---

# Bump Version

Source: AppOrOrgName-native; derived from `AGENTS.md`, `CLAUDE.md`, `pubspec.yaml`, and `CHANGELOG.md`.

Use this skill when a completed task may need app version and changelog updates. Do not bump automatically for every edit; avoid release metadata churn for trivial or docs-only changes unless the user requests it.

## Current Files

- App version lives in `pubspec.yaml` as `version: <major>.<minor>.<patch>+<build>`.
- Release notes live in `CHANGELOG.md`.
- Russian release notes may live in `CHANGELOG_ru.md` when the change is release-facing and the project expects both files.

## When To Bump

Bump the patch version when a completed change is major enough to be release-visible or project-critical, for example:

- user-visible app behavior,
- feature work,
- bug fix that affects users,
- transport, auth, persistence, analytics, routing, platform, or generated-code behavior,
- shared package change that ships with the app,
- release process or build configuration change.

Do not bump by default for:

- docs-only changes,
- agent skill changes,
- comments and typo fixes,
- local test-only changes with no shipped behavior,
- mechanical formatting,
- exploratory work that is not part of a release.

If the user explicitly asks for a release/version bump, follow that request.

## How To Bump

For patch releases, increment only the patch number:

```text
1.1.0 -> 1.1.1
```

Do not change the build number unless release instructions or the user explicitly require it.

For minor or major version changes, ask unless the release request clearly specifies the target version.

## Changelog Entry

Add a concise entry under `## Unreleased` unless the user is cutting a dated release section.

Use existing categories:

- `**ADDED**`:
- `**CHANGED**`:
- `**FIXED**`:
- `**REMOVED**`: when needed

Prefer issue links when the work is issue-backed:

```md
- **FIXED**: Preserve calendar payment filters after refresh, [#1](https://github.com/user_or_org_name/flutter_template_name/issues/1)
```

For non-issue work, describe the user-visible or operational behavior:

```md
- **CHANGED**: Hardened connectivity preflight for `Dio` and `HTTP` transports to reduce false offline banners.
```

## Validation

- After version/changelog edits, run markdown diagnostics and `make format` only if Dart files changed.
- For release-impacting app changes, use `verify-changes` to choose the appropriate full validation path.
- Report explicitly when no bump was made and why.

## Related

- [`commit-message`](../commit-message/SKILL.md)
- [`verify-changes`](../verify-changes/SKILL.md)
- [`CHANGELOG.md`](../../../CHANGELOG.md)
- [`pubspec.yaml`](../../../pubspec.yaml)
