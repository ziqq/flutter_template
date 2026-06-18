# AppOrOrgName Claude Code Skills

Auto-loaded skills for Claude Code in this repo. Claude selects a skill when a user request matches the `description` in that skill's frontmatter. Do not invoke repository skills by hand unless a slash command or workflow explicitly says so.

This file is the index and authoring policy for AppOrOrgName skills. It should explain what skills exist, how they are selected, and how new knowledge is merged into project-native workflows.

AppOrOrgName is a Flutter + Dart monorepo managed with FVM. The app lives under `lib/`, shared packages live under `packages/`, and validation is driven by `make` targets. Skills in this directory must reinforce that stack and the existing documentation; they must not introduce a parallel architecture or a generic external workflow.

## Core Principle

Never copy external skills as-is.

External skills, articles, framework docs, design-system references, accessibility docs, and examples from other projects are only raw material. The agent should extract useful ideas from them, then merge those ideas into AppOrOrgName-specific skills that use this repository's architecture, UI kit, commands, naming, and documentation.

Useful imported guidance should normally be handled in one of three ways:

- Merge it into an existing skill when it improves an existing AppOrOrgName workflow.
- Split it into multiple skills when the source mixes unrelated jobs.
- Combine several sources into one project-native skill when the sources cover the same local job from different angles.

Create a new skill only when the repository has a real new domain or repeatable task that is not already covered by an existing skill.

## What Skills Are For

- Add just-in-time context before the agent performs a task.
- Encode project-specific expectations that are too detailed for `CLAUDE.md` or `AGENTS.md`.
- Keep repeated workflows consistent: validation, review, versioning, commit messages, UI implementation, testing, and documentation updates.
- Point to canonical docs instead of duplicating long rule lists.
- Preserve project memory by reminding the agent to update `docs/**/*.md` when behavior, architecture, or workflows change.

`CLAUDE.md` and `AGENTS.md` are the table of contents and discussion contract. Detailed, task-specific behavior belongs in docs and skills.

## Canonical Project References

Read these before expanding or rewriting any skill:

- [`CLAUDE.md`](../../CLAUDE.md) — communication style, critical workflow rules, and repository overview.
- [`AGENTS.md`](../../AGENTS.md) — mandatory commands, architecture expectations, validation, and restrictions.
- [`README.md`](../../README.md) — project structure, setup, transport overview, and primary commands.
- [`docs/agent-skill-authoring.md`](../../docs/agent-skill-authoring.md) — team philosophy for designing, merging, filling, and reviewing skills.
- [`docs/architecture.md`](../../docs/architecture.md) — architecture overview.
- [`docs/conventions.md`](../../docs/conventions.md) — generated code, icons, prohibitions, and repository conventions.
- [`docs/features/`](../../docs/features/) — feature memory and domain-specific behavior notes.
- [`docs/rules/flutter.md`](../../docs/rules/flutter.md) — Flutter widget and controller rules.
- [`docs/rules/dart.md`](../../docs/rules/dart.md) — Dart language conventions.
- [`docs/rules/architecture.md`](../../docs/rules/architecture.md) — layering, feature structure, repositories, and data flow.
- [`docs/rules/models.md`](../../docs/rules/models.md) — model and serialization rules.
- [`docs/rules/testing-preferences.md`](../../docs/rules/testing-preferences.md) — unit, widget, fake, fixture, and validation patterns.
- [`docs/rules/ui.md`](../../docs/rules/ui.md) — visual design and accessibility baseline.
- [`docs/rules/workflow.md`](../../docs/rules/workflow.md) — tooling, logging, code generation, and execution flow.
- [`packages/ui/`](../../packages/ui/) — the actual AppOrOrgName UI kit, widgets, theme, fonts, icons, painters, and layout primitives.
- [`.vscode/tasks.json`](../../.vscode/tasks.json) — authoritative VS Code task entrypoints.

## Skill Conventions

- Each `SKILL.md` must have frontmatter with `name` and `description` only.
- The `description` must be a short trigger hint that helps Claude decide when to read the skill.
- Start the body with a `Source` line. Use `AppOrOrgName-native` for local skills or list external sources when ideas were adapted.
- Cross-references should use relative Markdown links.
- End each skill with a `Related` section linking sibling skills and canonical project docs.
- Keep skills operational and specific. Do not turn them into broad essays.
- Prefer rules that mention AppOrOrgName types, folders, packages, commands, and widgets over generic framework advice.

## Current Skills

| Skill | Purpose | Source |
|---|---|---|
| [`bump-version`](./bump-version/SKILL.md) | Handles patch version and changelog expectations after major completed changes. | AppOrOrgName-native. |
| [`code-documentation`](./code-documentation/SKILL.md) | Guides Dart and Flutter documentation comments so public APIs, widgets, controllers, repositories, screens, and files are easy to use and review. | AppOrOrgName-native, informed by Dart and Flutter documentation conventions. |
| [`commit-message`](./commit-message/SKILL.md) | Writes Conventional Commit messages matching repository branch, issue, and release style. | AppOrOrgName-native. |
| [`code-documentation`](./code-documentation/SKILL.md) | Guides Dart and Flutter documentation comments so public APIs, widgets, controllers, repositories, screens, and files are easy to use and review. | AppOrOrgName-native, informed by Dart and Flutter documentation conventions. |
| [`docs-maintenance`](./docs-maintenance/SKILL.md) | Decides whether durable docs need updates after behavior, architecture, workflow, validation, feature, UI, API, release, or agent-skill changes. | AppOrOrgName-native. |
| [`flutter-feature-module`](./flutter-feature-module/SKILL.md) | Guides feature-module changes across model, data, controller, widget, scope, tests, and docs. | AppOrOrgName-native. |
| [`repository-http-client`](./repository-http-client/SKILL.md) | Guides repository and transport work with `ApiClient$HTTP`, legacy Dio boundaries, JSON parsing, typed errors, and package ownership rules. | AppOrOrgName-native. |
| [`review-pr`](./review-pr/SKILL.md) | Reviews diffs against AppOrOrgName architecture, Flutter/Dart rules, UI kit usage, validation, and documentation drift. | AppOrOrgName-native. |
| [`ui-design-system`](./ui-design-system/SKILL.md) | Guides Flutter UI implementation and review through AppOrOrgName's `packages/ui` theme, widgets, states, and accessibility expectations. | AppOrOrgName-native, with external design/accessibility ideas merged into local UI rules. |
| [`verify-changes`](./verify-changes/SKILL.md) | Picks the smallest correct validation path based on changed files, generated-code impact, package boundaries, and test scope. | AppOrOrgName-native. |
| [`widget-test-patterns`](./widget-test-patterns/SKILL.md) | Guides widget tests through `WidgetTestUtil`, feature scopes, fakes, fixtures, and focused validation. | AppOrOrgName-native. |

All current skills contain task-specific guidance. Keep them synchronized with project docs as workflows evolve.

## Recommended Future Skills

There are no recommended future skills at the moment. Add a new one only when repeated project work shows a gap that is not already covered by the current skills or canonical docs.

## External Source Policy

External sources are allowed only as references to mine for useful constraints and patterns.

For the concrete source-adaptation matrix, use [`docs/agent-skill-authoring.md`](../../docs/agent-skill-authoring.md). It records how UI UX Pro Max, DESIGN.md examples, Impeccable, MDN ARIA, and WAI APG should be translated into AppOrOrgName skills without copying their stack-specific workflows.

Good external-source usage:

- Extract a useful principle from a source, then rewrite it in terms of AppOrOrgName folders, widgets, commands, and failure modes.
- Merge overlapping advice into an existing skill instead of creating duplicates.
- Discard source advice that conflicts with project docs or does not fit Flutter/Dart/mobile app work.
- Cite the source in the skill's `Source` line when it materially influenced the skill.

Bad external-source usage:

- Copying a skill because it is popular, branded, or recommended by a vendor.
- Keeping web, server, TypeScript, Tailwind, ARIA, Docker, or SEO rules when they do not apply to this Flutter app.
- Adding generic UI advice while ignoring AppOrOrgName's own `packages/ui` design system.
- Creating all-in-one skills that mix unrelated jobs such as testing, UI, commits, deployment, and architecture.

## UI Skill Policy

UI-related skills must be project-specific.

The useful question is not how an arbitrary external author builds UI. The useful question is how the agent should build AppOrOrgName UI with AppOrOrgName components.

A AppOrOrgName UI skill should therefore prioritize:

- `packages/ui/lib/src/theme/` for colors, typography, theme extensions, and visual tokens.
- `packages/ui/lib/src/widgets/` for reusable widgets such as inputs, loaders, layouts, pickers, text, icons, tabs, grouped lists, and common controls.
- `packages/ui/lib/src/painting/`, `packages/ui/lib/src/animations/`, and `packages/ui/lib/src/constants/` for visual primitives.
- Existing app feature widgets under `lib/src/feature/<domain>/widget/` as local examples.
- Accessibility and usability principles only after they are translated into Flutter semantics, focus behavior, contrast, hit targets, loading/error/empty states, and mobile navigation.

External UI sources such as design-system guides, UI critique checklists, accessibility documentation, and anti-pattern catalogs can inform this skill. They must be merged into AppOrOrgName's actual design system rather than copied as generic layout rules.

For non-trivial UI work, use the lifecycle in [`ui-design-system`](./ui-design-system/SKILL.md): inspect local context, shape the surface, build with the UI kit, critique hierarchy and cognitive load, audit accessibility and implementation quality, harden real-world data cases, then extract or document only proven repeated patterns.

## Expected Behavior Per Current Skill

### `verify-changes`

Should map changed files to the narrowest meaningful validation routine. The default escalation path is:

1. Run the smallest focused test or analyzer check that can falsify the change.
2. Run `make format` when Dart formatting may be affected.
3. Run `make check` for analyzer coverage.
4. Run `make test-unit-all` when cross-package behavior changed or when narrower tests are not enough.
5. Run or recommend `make gen` when generated outputs may be stale because of assets, localization, annotations, build_runner inputs, or API/model changes.

### `commit-message`

Should enforce repository commit style:

- Conventional Commit format.
- Use a meaningful scope when one exists, especially issue-linked scopes such as `github-123`.
- Describe the user-visible or domain behavior change, not low-level implementation noise.

### `bump-version`

Should remind that after a major completed change the patch version in [`pubspec.yaml`](../../pubspec.yaml) must be increased and the change must be reflected in [`CHANGELOG.md`](../../CHANGELOG.md). Trivial edits should not trigger version churn.

### `review-pr`

Should review with this priority order:

1. Behavioral regressions and user-visible risks.
2. Violations of Flutter, Dart, architecture, model, repository, and UI-kit rules.
3. Missing tests, insufficient validation, or stale generated outputs.
4. Documentation drift in `docs/**/*.md`, feature docs, `README.md`, `AGENTS.md`, or `CLAUDE.md`.

Findings should be concrete, severity-ordered, and tied to code behavior or repository rules.

### `code-documentation`

Should teach the agent to write caller-focused Dart and Flutter doc comments:

1. Explain what the API, widget, screen, file, or repository is for.
2. Explain how another developer should use it in this codebase.
3. Document non-obvious dependencies, scope assumptions, side effects, returns, and failure modes.
4. Prefer short examples when call order or embedding requirements are easier to show than describe.
5. Reject comments that merely restate the declaration or narrate internal implementation.

### `widget-test-patterns`

Should steer widget tests toward `WidgetTestUtil`, scoped feature examples, deterministic fakes, fixture alignment, focused assertions, and narrow validation before full-suite escalation.

### `repository-http-client`

Should enforce `ApiClient$HTTP` as the preferred path for JSON-object endpoints, preserve legacy Dio only where raw response contracts still require it, and keep parsing, typed errors, retries, connectivity, and package ownership boundaries explicit.

### `flutter-feature-module`

Should keep feature work aligned with `model` / `data` / `controller` / `widget` boundaries, controller state patterns, scope conventions, repository fakes, tests, and feature documentation.

### `docs-maintenance`

Should decide whether a change updates durable project knowledge and route that update to the most specific doc, while avoiding README churn and docs for purely mechanical edits.

## Documentation As Memory

Documentation is the durable project memory the agent can read later. When behavior, architecture, workflows, validation, UI patterns, or feature rules change, the relevant docs should be checked and updated in the same task when appropriate.

Preferred documentation targets:

- Feature behavior: `docs/features/<feature>.md`.
- Cross-cutting architecture or layering: `docs/architecture.md` or `docs/rules/architecture.md`.
- Flutter/UI implementation patterns: `docs/rules/flutter.md` or `docs/rules/ui.md`.
- Testing and validation patterns: `docs/rules/testing-preferences.md` or `docs/rules/workflow.md`.
- Repository-wide agent behavior: `AGENTS.md`, `CLAUDE.md`, or this README.

Do not update docs for mechanical edits that do not change behavior, workflow, or project knowledge.

## Validation Baseline

When a skill needs to recommend a standard full validation sequence, use this repository baseline:

```sh
make get
make gen
make format
make check
make test-unit-all
```

Use narrower checks when the task is clearly scoped and the change does not justify the full pipeline. Always assume FVM for direct Flutter or Dart commands.

## When Updating Skills

- Add new skill folders to the index above.
- Keep skill names aligned with concrete AppOrOrgName jobs, not external package names.
- Confirm every relative link resolves inside this repository.
- Keep `README.md` and each `SKILL.md` synchronized.
- Remove references to tools, stacks, folders, and commands that do not exist here.
- Prefer merging useful new guidance into an existing skill before creating another skill.
- If a skill becomes project-critical, link the canonical rule or feature doc it depends on.

## Out Of Scope

This directory is not the canonical place for product requirements, full architecture documentation, or generated-code instructions. Those belong in root docs and feature docs. Skills should stay compact, operational, and tied to the moments where the agent needs extra context.
