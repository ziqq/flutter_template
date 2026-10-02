---
name: dart-package-audit
description: "Audit Dart or Flutter package choices, source quality, tests, migrations, transitive cost, and whether an SDK or project-native primitive is sufficient."
---

# Dart Package Audit

Source: Adapted for this template; see the [Dart package policy](../../../docs/rules/dart-language.md#12-package-policy).

## Trigger

Use before adding a dependency, replacing an SDK primitive, adopting a Flutter package, or reviewing package-generated code.

## Audit

- State the exact capability gap; do not audit a package from its name or README alone.
- Inspect the package source, public API, tests, changelog, maintenance activity, platform support, and transitive dependencies.
- Check migration support, corruption/failure behavior, cancellation/disposal, performance characteristics, and whether the package hides a simpler SDK call.
- Compare the package with existing template primitives and ownership rules before proposing it.
- Treat package-specific claims, benchmarks, browser support, and stable-channel availability as versioned facts that require current verification.
- Do not add a dependency during review. If implementation is requested, record why the dependency is necessary and what validation will protect the boundary.

## Output

Report capability gap, alternatives, package evidence, operational risks, maintenance cost, license/platform concerns where relevant, and a clear decision: reject, defer, isolate behind an adapter, or adopt.

## Related

- [`flutter-architecture-policy`](../flutter-architecture-policy/SKILL.md)
- [`flutter-repository-http-client`](../flutter-repository-http-client/SKILL.md)
- [`quality-evidence-review`](../quality-evidence-review/SKILL.md)
- [`docs/rules/workflow.md`](../../../docs/rules/workflow.md)
