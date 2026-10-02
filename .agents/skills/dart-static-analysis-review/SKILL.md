---
name: dart-static-analysis-review
description: "Review Dart analyzer, linter, formatter, and Dart Code Metrics configuration and findings without weakening project quality gates or hiding generated code problems."
---

# Dart Static Analysis Review

Source: Adapted for this template; informed by the author's analyzer, linter, and Dart Code Metrics discussion.

## Trigger

Use when changing `analysis_options.yaml`, analyzer/linter rules, Dart Code Metrics, formatter settings, generated-code exclusions, or when a team proposes suppressing an analysis finding.

## Review

- Read the current `analysis_options.yaml`, `pubspec.yaml`, `Makefile`, generated-code policy, and CI/check recipe before changing a rule.
- Classify each finding as a real defect, intentional local convention, generated/vendor output, false positive, or tool/version mismatch. Do not silence it by broadening an exclusion until the source is understood.
- Prefer a local code correction over a global rule relaxation. If a rule conflicts with a deliberate template convention, document the narrow override and its scope.
- Keep analyzer, linter, formatter, and DCM responsibilities distinct. A metric threshold is not a substitute for tests, code review, or runtime evidence.
- Check that generated files remain generated and that exclusions do not hide handwritten code, unsafe parsing, missing disposal, or failing tests.
- Verify rule changes across app and workspace packages; package-specific overrides must have a concrete reason.

## Output

Report the finding, affected source, rule owner, intended invariant, proposed correction or narrow suppression, blast radius, and validation command.

## Validate

- Run `mise exec -- make format` and `mise exec -- make check` after rule/config changes.
- Run `mise exec -- make check-agent-config` if agent or skill configuration also changed.
- Add or update a focused regression test when the rule protects behavior rather than style.

## Related

- [`quality-evidence-review`](../quality-evidence-review/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`project-pr-review`](../project-pr-review/SKILL.md)
- [`docs/rules/dart.md`](../../../docs/rules/dart.md)
