# Testing and Tooling

Portable guidance adapted from the source application. Detailed SDK and project conventions remain in [Flutter rules](flutter.md), [Dart rules](dart.md), and [workflow rules](workflow.md).

## 1. Test the smallest falsifiable contract

Choose a check that would fail if the claimed behavior were wrong. Avoid tests that simply repeat the implementation.

## 2. Test states not implementation trivia

Assert observable loading, success, failure, empty, disabled, and recovery behavior. Cover races and lifecycle boundaries when they are part of the change.

## 3. Prefer fakes at ownership boundaries

Use deterministic repositories and fixtures. Mock platform boundaries where needed, not every private function. Reuse test/src/util fixtures.

## 4. Performance experiments

Record target device, SDK, build mode, workload, warm-up, repeated samples, uncertainty, and baseline. Passing tests are not performance evidence.

## 5. Static analysis and formatting

Run mise exec -- make format and mise exec -- make check. Fix source problems before suppressing diagnostics. Do not relax repository-wide rules to hide one error.

## 6. Package audit

Inspect dependencies, public exports, supported platforms, source, tests, and licensing. Run package tests from the owning package directory.

## 7. Code generation and localization

Edit local ARB inputs, annotations, schemas, and assets; never generated outputs. Run mise exec -- make gen. This template has application-owned localization.

## 8. Release and changelog checks

Keep root version 0.0.1+1. Template maintenance never triggers an automatic bump. Record relevant changes under Unreleased.

## 9. CI workflow design

Mise owns tool versions, Make owns public entrypoints, tool/dart/ci.dart owns orchestration. Reuse the same workflows locally and in CI.

## 10. Validation ladder

Start with focused tests; run make format, make check, and make test-unit-all before completion. Use make precommit for broad changes and before PR submission; add platform builds for platform changes.

## 11. Verification checklist

Report actual commands and outcomes, blocked checks, and unverified platforms. Run make check-agent-config for guidance changes. Never infer deployment from a local build.
