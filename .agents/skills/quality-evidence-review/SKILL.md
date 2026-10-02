---
name: quality-evidence-review
description: "Audit engineering recommendations, architecture claims, performance claims, dependency choices, and AI-generated code for evidence, scope, confidence, and falsifiable validation."
---

# Engineering Evidence Review

Source: Adapted for this template; see the [AI and evidence rules](../../../docs/rules/ai-agents.md) and repository contracts.

## Trigger

Use when someone asks whether code, a package, architecture, optimization, tutorial, generated change, or platform choice is good, bad, necessary, or production-ready.

## Review Discipline

- Separate observed facts, repository rules, official documentation, measured results, inference, and personal preference.
- Ask for the smallest missing artifact that can falsify the claim: source code, route contract, test, benchmark, profiler trace, browser support table, or failure reproduction.
- Inspect implementation and tests instead of trusting package names, README claims, benchmarks, diagrams, or link previews.
- Check the target Flutter/Dart version, platform, renderer, device, data volume, and lifecycle before generalizing a result.
- Prefer a minimal reproducible example and a focused regression test over a broad refactor justified by intuition.
- For a benchmark, require the question, workload, build mode, device, warm-up, iterations, variance, correctness guard, and user-visible decision. Numbers without context are not evidence of a product improvement.
- For runtime or rendering claims, separate VM, allocation/GC, build, layout, paint, raster, I/O, and platform-plugin evidence. Use the tool that measures the claimed layer.
- Report uncertainty and unrun checks explicitly. Do not claim deployment, staging readiness, provider support, or performance improvement from local configuration alone.

## Output

Use this structure:

- **Claim** — what is being asserted.
- **Evidence** — exact file, contract, test, measurement, or authoritative source.
- **Confidence** — high, medium, or low, with the reason.
- **Risk** — what fails if the claim is wrong.
- **Next falsifying check** — the smallest useful validation.
- **Recommendation** — implement, defer, narrow, or request missing context.

## Related

- [`project-pr-review`](../project-pr-review/SKILL.md)
- [`quality-ai-code-review`](../quality-ai-code-review/SKILL.md)
- [`dart-benchmark-review`](../dart-benchmark-review/SKILL.md)
- [`dart-runtime-performance-review`](../dart-runtime-performance-review/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/rules/workflow.md`](../../../docs/rules/workflow.md)
- [`docs/rules/testing-preferences.md`](../../../docs/rules/testing-preferences.md)
