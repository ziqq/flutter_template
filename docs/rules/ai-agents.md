# AI Agents and Evidence

Portable guidance adapted from the source application. Detailed SDK and project conventions remain in [Flutter rules](flutter.md), [Dart rules](dart.md), and [workflow rules](workflow.md).

## 1. Classify the request

Distinguish inspection, implementation, review, release, and external actions. Preserve the approved scope and current user corrections.

## 2. Inspect before generating

Read applicable instructions, docs, current code, tests, and git status. Preserve unrelated changes. Verify external contracts when relevant.

## 3. Separate facts from decisions

Label observed facts, assumptions, inferences, proposals, and unverified claims. Prefer source evidence and actual checks to confident wording.

## 4. Spec-first record

For substantial work define scope, alternatives, contracts, risks, acceptance criteria, and validation before editing. Existing user authorization remains valid; ask only about unresolved material decisions.

## 5. Review generated Dart and Flutter code

Check imports, real APIs, state ownership, lifecycle, cancellation, serialization, platform support, generated-code policy, and tests. AI output is not evidence of correctness.

## 6. Prompt for evidence not volume

Ask for a bounded deliverable with exact files, contracts, failure cases, and verification. Do not spawn delegated work unless explicitly authorized.

## 7. Evidence-based review output

Report actionable findings with severity, file location, failing scenario, evidence, and practical impact. Separate proven defects from suggestions.

## 8. Agent skill design

Keep one workflow per skill and link canonical docs. Translate external recommendations into actual repository types and commands. Validate names and local links.

## 9. Final handoff

State what changed, why, checks performed, and remaining limitations. Never claim remote effects from local checks. Do not bump the fixed template version.

## 10. AI review checklist

Check requested scope, unrelated edits, evidence, contract coverage, generated outputs, privacy, permissions, and honest validation boundaries.
