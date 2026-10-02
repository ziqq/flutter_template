---
name: quality-ai-code-review
description: "Review Copilot, ChatGPT, Claude, vibe-coded, or other AI-generated Dart and Flutter code for unsupported assumptions, wrapper noise, architectural drift, missing tests, and unverified claims."
---

# AI-Generated Code Review

Source: Adapted for this template; see the [AI-assisted development rules](../../../docs/rules/ai-agents.md).

## Trigger

Use when a diff, snippet, dependency choice, or architecture proposal was produced or materially shaped by an LLM, Copilot, code-generation tool, or "vibe coding" workflow.

## Review

- For non-trivial AI-assisted work, establish the problem, contracts, alternatives, acceptance criteria, and validation plan before reviewing generated implementation. Use [`project-spec-first-workflow`](../project-spec-first-workflow/SKILL.md) when the scope is still moving.
- Perform a fresh adversarial pass over the specification or plan. Look for contradictions, missing failure modes, implicit assumptions, overscoping, and instructions that conflict with repository rules.
- Treat generated code as untrusted until it compiles, satisfies analyzer rules, passes focused tests, and fits the local contracts.
- Reconstruct the code's ownership and data flow. Reject code the author or agent cannot explain at the level of lifecycle, error behavior, and invalidation.
- Look for generic `Container`/`GestureDetector` piles, responsive overflow, full-screen `setState`, unnecessary packages, pass-through abstractions, copied Clean Architecture, and hidden global registries.
- Check generated parsing for `dynamic`, unchecked casts, enum names, nullable assumptions, and swallowed errors.
- Compare generated UI with `packages/ui`, theme tokens, semantics, focus, loading/empty/error states, and localized text behavior.
- Compare generated controllers, scopes, repositories, and transport calls with `docs/architecture.md`, `docs/rules/flutter.md`, and the relevant feature docs.
- Inspect package source and current SDK compatibility before accepting an AI-proposed dependency or replacing an SDK primitive.
- Do not accept a passing build as proof of correctness. Require tests for the behavior, failure mode, and lifecycle contract that changed.
- Do not treat a long generated specification, a copied chat transcript, or a model's confident explanation as evidence by itself. Preserve only decisions that change implementation or validation.

## Output

Lead with concrete findings, not an accusation about authorship. For each finding include severity, file/line, violated contract, evidence, failure mode, and the smallest correction. If the code is sound, state what was verified and which checks remain unrun.

## Validate

- Run `mise exec -- make format` before checks.
- Use focused controller/widget/data tests, then `mise exec -- make check` when the change crosses packages or features.
- Run `mise exec -- make gen` only when generated inputs changed; never hand-edit generated output.

## Related

- [`quality-evidence-review`](../quality-evidence-review/SKILL.md)
- [`project-spec-first-workflow`](../project-spec-first-workflow/SKILL.md)
- [`project-pr-review`](../project-pr-review/SKILL.md)
- [`flutter-architecture-policy`](../flutter-architecture-policy/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
