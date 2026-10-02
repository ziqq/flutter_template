---
name: project-docs-maintenance
description: "Keep template project documentation accurate after behavior, architecture, workflow, validation, feature, UI, API, localization, release, agent, or skill changes. Use to choose the canonical documentation target and detect documentation drift."
---

# Docs Maintenance

Source: Adapted for this template; derived from `AGENTS.md`, `docs/architecture.md`, `docs/rules/documentation.md`, and the current `docs/` structure.

## Inspect First

- Read `AGENTS.md` for repository-wide guidance.
- Read `docs/architecture.md` and `docs/rules/documentation.md` for durable decisions and writing rules.
- Read `docs/features/<feature>.md` for changed feature behavior.
- Read package documentation when package ownership or contracts change.
- Read `.agents/README.md` and `docs/agent-skill-authoring.md` for agent configuration or skill changes.

## Update When

Document changes to user-visible behavior, business rules, edge cases, architecture, package ownership, transport contracts, validation commands, code generation, localization, release workflow, UI patterns, accessibility, or repeatable agent behavior.

Usually skip documentation for formatting, typo-only edits, behavior-preserving renames, isolated tests, or internal cleanup that creates no durable rule.

## Route The Change

| Change | Canonical target |
|---|---|
| Feature behavior | `docs/features/<feature>.md` |
| Cross-feature architecture | `docs/architecture.md` or `docs/rules/architecture.md` |
| Flutter/controller/scope patterns | `docs/rules/flutter.md` |
| UI and accessibility | `docs/rules/ui.md` |
| Models and serialization | `docs/rules/models.md` |
| Tests and fixtures | `docs/rules/testing-preferences.md` |
| Commands, codegen, CI | `docs/rules/workflow.md` or `docs/automation.md` |
| API transport boundaries | `docs/architecture.md` or `docs/architecture.md` |
| Agent skills and policy | `.agents/README.md` or `docs/agent-skill-authoring.md` |
| Release notes | Every applicable `CHANGELOG*.md` at that scope |

## Writing Rules

- Write documentation in English. Name Markdown files in lowercase kebab-case and update every repository link when
  renaming an existing document.
- Explain the durable contract and why it matters; do not narrate implementation history.
- Link to the canonical owner instead of duplicating long rules.
- Keep task tracking in issues rather than project docs.
- Never edit generated documentation or localization output by hand.
- Before changing a changelog, discover localized counterparts and update all applicable files equivalently.
- Validate every relative link.

## Related

- [`project-pr-review`](../project-pr-review/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/agent-skill-authoring.md`](../../../docs/agent-skill-authoring.md)
- [`docs/rules/documentation.md`](../../../docs/rules/documentation.md)
- [`docs/architecture.md`](../../../docs/architecture.md)
