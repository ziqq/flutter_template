---
name: release-version-policy
description: "Protect the fixed Flutter template version and review changelog or downstream release changes. Use when a task proposes a pubspec version bump, release metadata, or changelog edits."
---

# Template Version Policy

## Contract

- Keep the root `pubspec.yaml` version exactly `0.0.1+1`.
- Do not infer a version or build-number bump from task size, completion, or release visibility.
- Record relevant implementation changes under `Unreleased` in `CHANGELOG.md`.
- Do not change package versions unless explicitly requested.
- Downstream applications establish their own release policy after adopting the template.

## Workflow

1. Inspect the changed pubspec and changelog scope.
2. Preserve the fixed template version; do not propose automatic bumps.
3. Describe only verified changes and preserve existing changelog entries.
4. Regenerate pubspec constants through `mise exec -- make gen` when the source changes.
5. Report any explicit downstream release request separately from template maintenance.

## Related

- [`AGENTS.md`](../../../AGENTS.md)
- [`CHANGELOG.md`](../../../CHANGELOG.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
