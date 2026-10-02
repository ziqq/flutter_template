# Native UI Performance Harness

The shared helper is `packages/ui/example/tool/performance_harness.dart`, adapted from Tetradka's native integration
tools. It belongs to the UI example and is not imported into production or web code. The example declares
`integration_test` and `vm_service` as development dependencies.

## Measurements

- `PerformanceMemorySampler.connect()` connects to the current Dart isolate's VM Service. No service is reported as
  unavailable, rather than as zero memory consumption. Always dispose the sampler.
- `capture()` reads heap usage/capacity, external usage, and process RSS/high-water counters. Missing VM counters fail
  explicitly. Optional full GC runs outside a measured timeline window.
- `profilePerformanceScenario()` uses the SDK's `watchPerformance`, then adds build/raster durations over the supplied
  frame interval and memory samples before/after the action. Reports remain in `binding.reportData` for the driver.
- `enforceTargetBudget: true` fails on any build or raster sample over budget. Set it to `false` for an exploratory
  baseline. A zero/negative interval or missing frame samples is an error.
- `profileMemoryRecovery()` samples baseline, mounted, and released states, with unmount guaranteed in `finally`.
  RSS high-water growth does not mean retained live memory; compare heap, external, and current RSS as well.

## Scenario Ownership

Add a scenario in the owning example's `integration_test/` after the main implementation is approved. Import the
helper from `../tool/performance_harness.dart`, warm up the actual surface, and call it from an
`IntegrationTestWidgetsFlutterBinding` test. The scenario owns correctness checks, workload, warm-up, iterations,
budget, teardown, and report metadata. This port provides the measurement helper; it does not copy Tetradka's Liquid
Glass/shimmer workloads, which depend on different components.

Use `flutter drive --profile` with a physical native device, the scenario target, and an integration-test driver that
writes `binding.reportData`. Run from `packages/ui/example/` through Mise. `flutter test --profile` is unsupported;
ordinary widget tests, desktop debug execution, and simulator builds do not establish device performance.

Record device/OS, build mode, renderer, logical constraints, DPR, refresh rate and chosen budget, workload, warm-up,
iteration count, variance, and a visual/behavioral correctness guard alongside every result. Keep VM-service sampling
and GC outside the action. The helper measures build/raster pipeline stages, not presented FPS or touch latency.
Do not claim improvements, leak freedom, or release acceptance from source inspection or an unavailable sampler.

## Local Checks

`make format` and `make check` include the helper. No benchmark or performance result is implied by these checks.
Physical-device baseline and follow-up measurements remain a separate step.
