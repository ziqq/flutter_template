# Initialization

`lib/src/feature/initialization/data/initialize_dependencies.dart` owns the ordered startup steps and builds
`Dependencies`. It connects storage, restores settings, applies analytics consent, initializes clients/controllers,
and prepares navigation and logging. Preserve dependency order when adding a step.

Each executed step records its name, execution index, and Stopwatch duration in an immutable `InitializationStats`
snapshot. The total sums measured step execution time; progress callbacks and pre-start work are outside this total.
The `finally` block records a failing step before the existing startup error path propagates the failure.

The developer statistics screen reads this snapshot. It does not restart initialization or fetch remote metrics.
Tests cover immutable snapshots, totals, zero duration, stable sorting, and empty/filled diagnostic views.

This timing instrumentation does not implement rollback or disposal of partially initialized dependencies.
A downstream application must define that lifecycle contract before introducing resources that need rollback.
