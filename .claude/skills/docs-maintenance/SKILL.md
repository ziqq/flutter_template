---
name: docs-maintenance
description: "Use when: deciding whether AppOrOrgName docs must be updated after behavior, architecture, workflow, validation, feature, UI, API, localization, release, or agent-skill changes."
---

# Docs Maintenance

Source: AppOrOrgName-native; derived from `AGENTS.md`, `CLAUDE.md`, `docs/decisions.md`, `docs/rules/documentation.md`, and existing `docs/**` structure.

Use this skill when a change may leave project memory stale. The goal is not more documentation; the goal is to keep the durable docs accurate enough that future agents and maintainers can make correct decisions.

## First Sources To Inspect

- `AGENTS.md` and `CLAUDE.md` for repository-wide instructions and documentation references.
- `docs/decisions.md` for architectural decisions and open documentation policies.
- `docs/rules/documentation.md` for writing style.
- `docs/features/<feature>.md` when changing feature behavior.
- Package docs such as `packages/api/README.md` and `packages/api/docs/architecture.md` when package boundaries change.
- `.claude/skills/README.md` and `docs/agent-skill-authoring.md` when changing skills or agent behavior.

## Update Docs When

- User-visible behavior, state, edge cases, navigation, validation, permissions, or error handling changes.
- Feature workflow or business rules change.
- Architecture, layering, package ownership, transport behavior, controller patterns, repository contracts, or generated-code rules change.
- Validation commands, test strategy, code generation, localization, release, or CI workflow changes.
- UI patterns, `packages/ui` usage, accessibility expectations, or design-system rules change.
- A bug fix reveals a durable invariant or known pitfall that should be remembered.
- A new or changed skill alters how agents should perform recurring work.

## Usually Do Not Update Docs For

- Pure formatting.
- Typo-only fixes.
- Renames that do not change API meaning or workflow.
- Test-only changes that do not establish a reusable testing pattern.
- Internal cleanup with no behavior, contract, workflow, or convention change.
- Generated files or vendor-managed outputs.

If unsure, prefer a small note in the most specific doc over broad README churn.

## Where To Update

| Change | Preferred Target |
|---|---|
| Feature behavior or workflow | `docs/features/<feature>.md` |
| Cross-feature architecture or layering | `docs/architecture.md` or `docs/rules/architecture.md` |
| Flutter, controller, scope, widget patterns | `docs/rules/flutter.md` |
| UI kit, visual rules, accessibility | `docs/rules/ui.md` |
| Models, parsing, enum serialization | `docs/rules/models.md` |
| Testing harnesses, fakes, fixtures | `docs/rules/testing-preferences.md` |
| Commands, codegen, logging, workflow | `docs/rules/workflow.md` |
| API package transport boundaries | `packages/api/README.md` or `packages/api/docs/architecture.md` |
| Product goals, milestones, decisions | `docs/goals.md`, `docs/milestones.md`, or `docs/decisions.md` |
| Agent skills and authoring policy | `.claude/skills/README.md` or `docs/agent-skill-authoring.md` |
| Release-visible changes | `CHANGELOG.md` and, when required, `CHANGELOG_ru.md` |

## Writing Rules

- Write docs in English.
- Keep entries brief and decision-oriented.
- Explain why and when a rule matters, not only what changed.
- Use existing terminology and file naming; docs under `docs/` should use lowercase paths.
- Link to issues instead of copying full issue bodies.
- Do not duplicate long rules from another doc; link to the canonical source and add only task-specific context.
- Do not hand-edit generated docs or generated localization files.

## Review Checklist

- Did the change alter durable project knowledge?
- Is there an existing doc that should own this rule?
- Is the note specific enough for a future maintainer to act on?
- Did the update avoid duplicating task management from GitHub issues?
- Are links relative and valid inside the repository?
- If no docs were updated, can you explain why the change is mechanical or local-only?

## Related

- [`verify-changes`](../verify-changes/SKILL.md)
- [`review-pr`](../review-pr/SKILL.md)
- [`flutter-feature-module`](../flutter-feature-module/SKILL.md)
- [`repository-http-client`](../repository-http-client/SKILL.md)
- [`ui-design-system`](../ui-design-system/SKILL.md)
- [`docs/agent-skill-authoring.md`](../../../docs/agent-skill-authoring.md)
- [`docs/rules/documentation.md`](../../../docs/rules/documentation.md)
- [`docs/decisions.md`](../../../docs/decisions.md)
