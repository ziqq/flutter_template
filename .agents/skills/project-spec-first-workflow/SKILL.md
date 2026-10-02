---
name: project-spec-first-workflow
description: "Plan non-trivial template features and AI-assisted changes by stabilizing decisions, contracts, milestones, acceptance criteria, and documentation before implementation."
---

# Project Spec-First Workflow

Source: Adapted for this template; adapted from the author's "idea to codebase" LLM workflow. The source describes a personal process; this skill keeps only the parts that improve template's existing contract-first process.

## Trigger

Use for a new feature, broad refactor, cross-package change, protocol change, release-visible architecture decision, or AI-assisted implementation with unresolved scope.

Do not use the full workflow for a trivial localized fix whose contract and validation are already clear.

## Workflow

1. **Explore.** Inspect the repository, relevant feature docs, package contracts, tests, backend code, and current dirty-tree state. Compare viable approaches and record unresolved questions.
2. **Define scope.** State what the change must do, what it explicitly will not do, affected packages/platforms, ownership boundaries, risks, and the smallest acceptable implementation.
3. **Specify.** Turn decisions into a focused plan or spec with data flow, API/protocol shape, state transitions, failure modes, migration needs, tests, and documentation targets. Preserve rejected alternatives when they explain a constraint.
4. **Attack the specification.** In a fresh review pass, search for contradictions, implicit assumptions, missing acceptance criteria, overscoping, race conditions, lifecycle holes, and claims that lack evidence. Resolve material gaps before coding.
5. **Scaffold only what is needed.** Update the relevant canonical docs, feature structure, agent instructions, or test plan. Do not create a large documentation hierarchy or raw dialogue archive for a routine feature.
6. **Implement by milestone.** Each milestone must have observable acceptance criteria: a passing focused test, a verified contract, a build/analyzer gate, or a measured performance bound. Keep changes narrow and reversible.
7. **Synchronize memory.** Before handoff or PR, update durable feature/architecture/workflow docs when implementation changed the original assumptions. Re-check upcoming work if the decision affects it.

## template Constraints

- `AGENTS.md` is canonical; `CLAUDE.md` is only a compatibility entrypoint.
- Read `docs/rules/flutter.md`, `docs/rules/architecture.md`, and the relevant feature/package docs before implementation.
- Ask before changing another package, shared/public API, generated source, version, or external system when approval is not already implied.
- Keep acceptance criteria falsifiable. "Works correctly" is not enough; name the test, contract, device, or measured behavior.
- Treat generated or AI-proposed code as untrusted until it matches local patterns, compiles, passes focused tests, and survives adversarial review.

## Output

Produce a concise decision record or plan with scope, alternatives, chosen approach, risks, acceptance criteria, validation commands, and documentation updates. If a material decision remains unresolved, stop before implementation and ask for it.

## Related

- [`quality-ai-code-review`](../quality-ai-code-review/SKILL.md)
- [`quality-evidence-review`](../quality-evidence-review/SKILL.md)
- [`project-docs-maintenance`](../project-docs-maintenance/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/agent-skill-authoring.md`](../../../docs/agent-skill-authoring.md)
- [`docs/rules/workflow.md`](../../../docs/rules/workflow.md)
