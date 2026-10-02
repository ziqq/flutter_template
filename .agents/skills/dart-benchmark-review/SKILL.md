---
name: dart-benchmark-review
description: "Design or review Dart microbenchmarks and performance experiments for representative workloads, variance, build modes, and actionable conclusions."
---

# Dart Benchmark Review

Source: Adapted for this template; informed by the author's Dart benchmark analysis.

## Trigger

Use when someone presents benchmark numbers, compares Dart/Flutter implementations, or wants to justify an optimization with a microbenchmark.

## Review

- Reframe the benchmark as an experiment: state the user-visible question and the decision the result should change.
- Define the workload, input distribution, output correctness, device/CPU, Dart/Flutter version, build mode, warm-up, iteration count, and measurement unit.
- Separate throughput, latency, allocation, memory, frame time, startup, and I/O. Do not let a fast synthetic loop stand in for the real bottleneck.
- Check that the compiler cannot eliminate or simplify the work, that inputs are not accidentally constant, and that both alternatives do equivalent work.
- Report variance, outliers, confidence limits or repeated runs, and the effect size. A tiny percentage change may be noise or irrelevant to the product.
- Compare against a representative baseline and include a correctness test. Benchmark code is not production validation.
- Prefer profile/release measurements for Flutter runtime decisions; label debug/JIT measurements as exploratory.

## Output

Use: question, setup, workload, correctness guard, measurements, uncertainty, interpretation, decision, and next production-level validation. Explicitly mark conclusions that remain speculative.

## Validate

- Repeat runs on representative data and at least one target device when the claim is user-visible.
- Pair microbenchmarks with DevTools/FrameTiming/memory evidence when the issue is Flutter performance.
- Keep the benchmark reproducible and avoid adding a benchmark-only abstraction to production code.

## Related

- [`dart-runtime-performance-review`](../dart-runtime-performance-review/SKILL.md)
- [`quality-evidence-review`](../quality-evidence-review/SKILL.md)
- [`flutter-rendering-performance-review`](../flutter-rendering-performance-review/SKILL.md)
