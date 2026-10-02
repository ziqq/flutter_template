# Flutter Template Agent Skills

`.agents/skills` is the repository-owned skill directory for Codex, Codex cloud, and other cloud agents that support the Agent Skills format. Keep every skill portable: its core workflow must live in `SKILL.md` and must not depend on a Codex-only configuration file.

Codex discovers these skills automatically. Other agents may discover the same directory or read a skill explicitly as repository guidance. A user may invoke a skill explicitly, for example `$project-verify-changes`, or let an agent select it from the frontmatter description.

## Guidance Layers

| Layer | Purpose |
|---|---|
| [`AGENTS.md`](../AGENTS.md) | Canonical repository-wide agent contract. |
| [`CLAUDE.md`](../CLAUDE.md) | Compatibility entrypoint for agents that load Claude-style guidance. |
| [`docs/`](../docs/) | Durable architecture, workflow, feature, and product knowledge. |
| `.agents/skills/<name>/SKILL.md` | Just-in-time workflow for one repeatable task. |
| [`.codex/`](../.codex/) | Optional local Codex configuration and custom agents. |
| [`.claude/`](../.claude/) | Claude Code adapter, commands, permissions, hooks, and symlink to portable skills. |

Do not duplicate detailed project rules in root instructions or skills. Point to the canonical document and add only the task-specific decisions an agent needs after the skill triggers.

## Documentation Routing

Keep durable policy in `docs/rules/`, feature contracts in `docs/features/`, package-owned contracts in the relevant
`packages/*/docs/`, and executable evidence in tests or package examples. A skill may summarize the workflow, but it
must point to the canonical owner instead of becoming a second source of truth. Do not create a separate generic
reference layer for material that already belongs to one of these owners.

## Skill Format

Each skill directory must contain a `SKILL.md` with exactly `name` and `description` in YAML frontmatter:

```yaml
---
name: project-verify-changes
description: "Select and run validation for template Flutter, Dart, documentation, generated-code, package, test, and configuration changes."
---
```

Requirements:

- Use lowercase hyphenated names and make the folder name match `name`.
- Describe both the job and its trigger context in `description`.
- Keep instructions concise, imperative, and template-specific.
- Use repository-relative Markdown links.
- End with a `Related` section linking canonical docs and adjacent skills.
- Put deterministic helpers in `scripts/`, detailed optional material in `references/`, and output resources in `assets/` only when they are genuinely needed.
- Treat `agents/openai.yaml` as optional UI metadata. A skill must remain usable without it so cloud agents can share the same directory.
- Compatibility symlinks such as `.claude/skills → ../.agents/skills` may expose the same skills to another agent, but `.agents/skills` remains the only source of truth.

## Current Skills

The folder name is the discovery name. Prefixes are namespaces; suffixes describe
the operation (`-review`, `-audit`, `-policy`, `-tests`, `-module`).

| Namespace | Skill | Tier | Purpose |
|---|---|---|---|
| `backend` | [`backend-auth-protocol-review`](./skills/backend-auth-protocol-review/SKILL.md) | P0 | Reviews JWT/OAuth, sessions, API contracts, health protocols, and RPC boundaries. |
| `data` | [`data-local-storage-review`](./skills/data-local-storage-review/SKILL.md) | P1 | Reviews local persistence, time values, migrations, recovery, caches, and ownership. |
| `dart` | [`dart-async-review`](./skills/dart-async-review/SKILL.md) | P0 | Reviews Futures, streams, queues, Pub/Sub, cancellation, and lifecycle ownership. |
| `dart` | [`dart-benchmark-review`](./skills/dart-benchmark-review/SKILL.md) | P1 | Reviews Dart microbenchmarks as experiments with representative workloads and uncertainty. |
| `dart` | [`dart-isolate-review`](./skills/dart-isolate-review/SKILL.md) | P1 | Reviews isolate ownership, message protocols, cancellation, watchdogs, and data transfer. |
| `dart` | [`dart-iterable-review`](./skills/dart-iterable-review/SKILL.md) | P0 | Reviews Dart Iterable laziness, traversal, complexity, and allocation. |
| `dart` | [`dart-package-audit`](./skills/dart-package-audit/SKILL.md) | P1 | Audits package source, tests, maintenance, platform support, and dependency cost. |
| `dart` | [`dart-resource-lifecycle-review`](./skills/dart-resource-lifecycle-review/SKILL.md) | P0 | Reviews async initialization, cancellation, rollback, and deterministic cleanup. |
| `dart` | [`dart-runtime-performance-review`](./skills/dart-runtime-performance-review/SKILL.md) | P1 | Reviews Dart VM, allocation, GC, JIT/AOT, profiling, and pragma claims. |
| `dart` | [`dart-static-analysis-review`](./skills/dart-static-analysis-review/SKILL.md) | P1 | Reviews analyzer, linter, formatter, DCM, and suppression changes. |
| `flutter` | [`flutter-adaptive-layout-review`](./skills/flutter-adaptive-layout-review/SKILL.md) | P0 | Reviews constraints, breakpoints, text scale, localization, and adaptive states. |
| `flutter` | [`flutter-architecture-policy`](./skills/flutter-architecture-policy/SKILL.md) | P0 | Applies the opinionated dependency and architecture policy for new Flutter code. |
| `flutter` | [`flutter-canvas-painters`](./skills/flutter-canvas-painters/SKILL.md) | Core | Builds and reviews high-performance Flutter canvas painters and custom render objects. |
| `flutter` | [`flutter-feature-module`](./skills/flutter-feature-module/SKILL.md) | Core | Guides feature changes across model, data, controller, widget, scope, tests, and docs. |
| `flutter` | [`flutter-form-state-review`](./skills/flutter-form-state-review/SKILL.md) | P0 | Reviews SDK-native form state, validation, focused rebuilds, async fields, and disposal. |
| `flutter` | [`flutter-navigation-review`](./skills/flutter-navigation-review/SKILL.md) | P1 | Reviews routing, route contracts, deep links, nested stacks, back behavior, and restoration. |
| `flutter` | [`flutter-network-debugging`](./skills/flutter-network-debugging/SKILL.md) | P1 | Debugs development HTTP/WebSocket traffic with redacted proxy evidence. |
| `flutter` | [`flutter-overlay-positioning-review`](./skills/flutter-overlay-positioning-review/SKILL.md) | P1 | Reviews anchor-following overlays across scroll, transforms, lifecycle, and accessibility. |
| `flutter` | [`flutter-renderer-selection`](./skills/flutter-renderer-selection/SKILL.md) | P0 | Chooses widgets, CustomPaint, or RenderObject from context and measurements. |
| `flutter` | [`flutter-rendering-performance-review`](./skills/flutter-rendering-performance-review/SKILL.md) | P0 | Reviews rebuild, layout, paint, raster, invalidation, and frame evidence. |
| `flutter` | [`flutter-repository-http-client`](./skills/flutter-repository-http-client/SKILL.md) | Core | Handles `ApiClient$HTTP`, raw-response boundaries, parsing, and typed transport errors. |
| `flutter` | [`flutter-state-layer-review`](./skills/flutter-state-layer-review/SKILL.md) | P0 | Reviews feature boundaries between widgets, state, data, repositories, and scopes. |
| `flutter` | [`flutter-state-management`](./skills/flutter-state-management/SKILL.md) | Core | Chooses and builds controllers, sealed states, `StateConsumer`, scopes, and local notifiers. |
| `flutter` | [`flutter-ui-design-system`](./skills/flutter-ui-design-system/SKILL.md) | Core | Builds and reviews Flutter UI through `packages/ui` and accessibility rules. |
| `flutter` | [`flutter-widget-lifecycle-review`](./skills/flutter-widget-lifecycle-review/SKILL.md) | P0 | Reviews StatefulWidget lifecycle, inherited dependencies, updates, and disposal. |
| `flutter` | [`flutter-widget-tests`](./skills/flutter-widget-tests/SKILL.md) | Core | Applies template widget-test harnesses, fakes, fixtures, and state assertions. |
| `flutter` | [`flutter-webview-debugging`](./skills/flutter-webview-debugging/SKILL.md) | P1 | Debugs WebView and Custom Tabs content, redirects, storage, JS, and platform inspection. |
| `project` | [`project-code-documentation`](./skills/project-code-documentation/SKILL.md) | Core | Writes caller-focused Dart and Flutter documentation. |
| `project` | [`project-commit-message`](./skills/project-commit-message/SKILL.md) | Core | Composes Conventional Commit messages and PR titles. |
| `project` | [`project-docs-maintenance`](./skills/project-docs-maintenance/SKILL.md) | Core | Routes durable behavior and workflow changes to canonical documentation. |
| `project` | [`project-pr-review`](./skills/project-pr-review/SKILL.md) | Core | Reviews diffs for regressions, architecture, tests, generated output, UI, and docs drift. |
| `project` | [`project-spec-first-workflow`](./skills/project-spec-first-workflow/SKILL.md) | P0 | Stabilizes scope, contracts, adversarial review, milestones, acceptance criteria, and docs before broad implementation. |
| `project` | [`project-verify-changes`](./skills/project-verify-changes/SKILL.md) | Core | Selects the smallest meaningful validation path and escalation level. |
| `quality` | [`quality-ai-code-review`](./skills/quality-ai-code-review/SKILL.md) | P0 | Reviews LLM-generated Dart/Flutter code for drift, omissions, and unsupported assumptions. |
| `quality` | [`quality-evidence-review`](./skills/quality-evidence-review/SKILL.md) | P0 | Separates evidence, inference, opinion, confidence, and falsifying checks. |
| `release` | [`release-version-policy`](./skills/release-version-policy/SKILL.md) | Core | Preserves the fixed template version and relevant Unreleased notes. |
| `web` | [`web-capability-review`](./skills/web-capability-review/SKILL.md) | P1 | Reviews Flutter Web, JS/TS, PWA, WebView/TWA, and browser capability trade-offs. |

## Naming And Organization

- Keep skills flat under `.agents/skills/`; use prefixes instead of nested folders so automatic discovery and explicit invocation remain predictable.
- Use `dart-*` for language/runtime behavior, `flutter-*` for framework/UI/app architecture, `backend-*` for server/API/auth contracts, `data-*` for persistence, `web-*` for browser/platform concerns, `quality-*` for evidence and generated-code review, `project-*` for repository workflow, and `release-*` for versioning.
- Do not encode a package name as the primary namespace. A package is evidence or an implementation detail; the skill should describe the recurring template task.
- Keep one skill focused on one decision surface. Link implementation companions instead of duplicating their checklists.

## Authoring Workflow

1. Confirm that the task is repeated and project-specific enough to justify a skill.
2. Inspect [`docs/agent-skill-authoring.md`](../docs/agent-skill-authoring.md), nearby code, and canonical rules.
3. Merge guidance into an existing skill when it already owns the workflow.
4. Create a new skill only for a distinct recurring job.
5. Keep external material as source input; translate useful constraints into template folders, types, commands, tests, and failure modes.
6. Update this index when the skill set changes.
7. Run `mise exec -- make check-agent-config`.

## Canonical References

- [Project overview](../README.md)
- [Agent skill authoring](../docs/agent-skill-authoring.md)
- [Local and cloud agent setup](../docs/agent-configuration.md)
- [Architecture](../docs/architecture.md)
- [Conventions](../docs/conventions.md)
- [Flutter rules](../docs/rules/flutter.md)
- [Dart rules](../docs/rules/dart.md)
- [Model rules](../docs/rules/models.md)
- [Testing preferences](../docs/rules/testing-preferences.md)
- [UI rules](../docs/rules/ui.md)
- [Workflow rules](../docs/rules/workflow.md)
- [VS Code tasks](../.vscode/tasks.json)

## Validation

`mise exec -- make check-agent-config` validates skill frontmatter, names, links, placeholders, custom-agent required fields, and the project Codex schema declaration. It is also part of `make check` and `make precommit`.
