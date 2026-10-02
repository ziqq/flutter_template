---
name: dart-runtime-performance-review
description: "Review Dart VM, JIT/AOT, allocation, garbage collection, profiling, and runtime-performance claims without cargo-culting VM-specific optimizations."
---

# Dart Runtime Performance Review

Source: Adapted for this template; informed by the author's Dart VM, garbage-collection, and pragma analyses.

## Trigger

Use when a change is justified by Dart VM behavior, garbage collection, allocation, JIT/AOT differences, `@pragma`, startup time, memory pressure, or a runtime benchmark.

## Review

- Identify the target build mode, device/CPU, Dart/Flutter version, workload, and user-visible budget before discussing runtime behavior.
- Separate build, VM execution, allocation/GC, Flutter frame pipeline, I/O, and platform-plugin costs. A VM explanation must not substitute for a frame trace or profile.
- Inspect allocation rate, object lifetime, retained references, collection frequency, and payload size before recommending pooling, caching, or object reuse.
- Prefer algorithmic, data-shape, batching, and lifecycle improvements over VM-specific hints.
- Treat `@pragma` as a tool hint with tool-specific semantics. Never add a pragma without a measured target, a current authoritative explanation, and a benchmark that demonstrates a relevant benefit.
- Compare debug/JIT results with profile or release AOT results. Do not use hot-reload behavior as release performance evidence.
- Treat VM internals as versioned implementation details; re-verify them against current Dart/Flutter documentation when they affect a production decision.

## Output

Report the claim, runtime layer involved, evidence, target mode/device, allocation or GC hypothesis, confidence, and falsifying measurement. Recommend the simplest change that improves the measured bottleneck.

## Validate

- Use DevTools timeline/memory views, `FrameTiming`, a representative profile build, or a repeatable benchmark as appropriate.
- Record warm-up, iteration count, payload, variance, and build mode.
- Run focused tests and `mise exec -- make check`; do not claim a performance win from analyzer or unit-test success.

## Related

- [`dart-benchmark-review`](../dart-benchmark-review/SKILL.md)
- [`quality-evidence-review`](../quality-evidence-review/SKILL.md)
- [`flutter-rendering-performance-review`](../flutter-rendering-performance-review/SKILL.md)
- [`docs/rules/dart.md`](../../../docs/rules/dart.md)
