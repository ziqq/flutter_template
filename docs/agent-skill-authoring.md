# Agent Skill Authoring

## Ownership

Keep reusable task workflows in `.agents/skills/<name>/SKILL.md` and index them in
[.agents/README.md](../.agents/README.md). `.claude/skills` only exposes that directory through a symlink.
Keep durable policy in [docs/rules](rules/), feature contracts in [docs/features](features/),
and executable examples and evidence in tests. Do not duplicate those contracts inside skills.

## Format

Use exactly `name` and `description` in YAML frontmatter. Names are lowercase kebab-case and match the directory.
Describe both the job and when it should trigger. Keep skills flat, with `dart-`, `flutter-`, `project-`,
`quality-`, `backend-`, `data-`, `web-`, or `release-` prefixes. Optional `agents/openai.yaml` is UI metadata,
not a dependency of the workflow. Add scripts, references, and assets only when the skill needs them.

## Adaptation workflow

1. Inspect the recurring task, existing skills, actual code, and canonical rules.
2. Reuse an existing skill when it already owns the decision; avoid duplicate generic advice.
3. Translate source material into actual template types, paths, commands, and failure cases.
4. Keep the approved scope and permissions. Skills cannot override the user's instructions.
5. Link related skills and canonical documentation with relative Markdown links.
6. Update the index and run `mise exec -- make check-agent-config`.

The app owns `lib/src/common/router`, `lib/src/common/api_client`, and local ARB localization.
There are no separate core/API/localization packages. The UI kit is `packages/ui`, exported through `package:ui/ui.dart`.
Use `mise exec -- make <target>`; see [automation](automation.md). Keep the template version at `0.0.1+1`.
Do not import source product features, backend assumptions, secret IDs, machine paths, or release instructions.

## Evidence

A skill should ask for the smallest check capable of falsifying its claim. Distinguish code inspection,
analyzer/test success, platform builds, runtime measurements, and remote effects.
See [AI and evidence rules](rules/ai-agents.md) and [testing and tooling](rules/testing-and-tooling.md).
