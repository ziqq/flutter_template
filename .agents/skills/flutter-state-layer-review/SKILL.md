---
name: flutter-state-layer-review
description: "Review template Flutter feature boundaries between widgets, state/controllers, repositories, data sources, scopes, and clients without imposing speculative architecture."
---

# Flutter State And Layer Review

Source: Adapted for this template; see [architecture](../../../docs/architecture.md), [Flutter patterns](../../../docs/rules/flutter-patterns.md#3-controller-boundaries),
and the existing state-management skill.

## Trigger

Use when reviewing a feature structure, state-management choice, controller interaction, repository boundary, Scope, or proposed Clean Architecture/GetX/MVVM layout.

## Boundaries

- Treat widgets as configuration, composition, lifecycle, and presentation of observable state — not as repositories or hidden application coordinators.
- Keep feature code in the project shape: `model/`, `data/`, `controller/`, and `widget/` under `lib/src/feature/<domain>/`.
- Keep repositories behind `IFooRepository`, with `FooRepository` and a visible-for-testing fake where the feature needs one.
- Keep controllers independent. Cross-controller orchestration belongs in a widget, Scope, composition root, or explicit shared dependency — never in hidden controller-to-controller reads.
- Expose state and commands through the feature Scope using documented aspects; do not rebuild a whole subtree for an unrelated state slice.
- Do not introduce BLoC, a state-manager package, a domain layer, or an interface-per-class merely to satisfy a diagram. The abstraction must own a real behavior, lifecycle, boundary, or test seam.
- Preserve explicit dependency direction: widgets may consume controllers; controllers may depend on repositories; repositories may depend on transport/storage clients; lower layers must not import feature widgets.

## Review Questions

- Who owns mutable state and who disposes it?
- Is this value a widget configuration, ephemeral local state, application state, or persisted data?
- Can the behavior be tested through a public API with a deterministic fake?
- Does the proposed layer reduce coupling, or only rename the same object and add indirection?
- Are state snapshots, commands, and side effects distinct?

## Output

Report violations by boundary, evidence from imports/types/lifecycle, the smallest project-native alternative, and whether a migration is actually requested. Do not perform a broad architecture rewrite as part of review.

## Validate

- Read the applicable feature doc and canonical architecture/state rules before judging a new boundary.
- Run focused controller/widget tests after implementation; escalate to `make test-unit-all` for shared packages or cross-feature behavior.

## Related

- [`flutter-state-management`](../flutter-state-management/SKILL.md)
- [`flutter-feature-module`](../flutter-feature-module/SKILL.md)
- [`flutter-architecture-policy`](../flutter-architecture-policy/SKILL.md)
- [`docs/architecture.md`](../../../docs/architecture.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
