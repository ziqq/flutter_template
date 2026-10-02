# Flutter template

A Flutter application template by [ziqq](https://github.com/ziqq), based on the controller patterns from
[Plague Fox](https://plugfox.dev/).

## Getting started

Install [Mise](https://mise.jdx.dev/getting-started.html), then clone the template:

```sh
git clone https://github.com/ziqq/flutter_template.git
cd flutter_template
mise trust
mise install
mise exec -- make get
mise exec -- flutter run --flavor dev --dart-define-from-file=config/development.json
```

`mise.toml` pins Flutter, GNU Make, Java, and the macOS Ruby/CocoaPods tools. `mise.lock` records resolved tool versions.
Use `mise exec -- make <target>` when Mise is not activated in your shell. With shell activation, `make <target>` uses
the same tools. On Windows, install Git for Windows and run the Bash-based workflows from Git Bash.

All environments use the same Flutter SDK. Android flavors are `dev`, `stage`, `prod`, `gms`, and `hms`; iOS has
`dev` and `prod` schemes. Keep application identifiers and signing settings specific to your project.
Firebase/Huawei configuration files and release signing credentials are not supplied by this template.
Minimum native targets are Android API 24, iOS 15, and macOS 12. The UI example uses Flutter's CocoaPods integration
for native image-library and integration-test dependencies on Apple platforms.

Launch VS Code from the Mise environment (`mise exec -- code .`) so the Dart extension resolves the pinned SDK.
The supplied tasks invoke Make through Mise.

## Customize the template

```sh
mise exec -- dart run tool/dart/rename_project.dart \
  --name="project" --organization="tld.domain" --description="My project description"
```

Replace `AppOrOrgName` and template repository URLs, including in hidden files. Configure `config/*.json` and service
integrations before enabling Firebase, Sentry, authentication, or bug-report delivery.

## Commands

| Action | Command |
|---|---|
| Dependencies | `mise exec -- make get` |
| Code generation | `mise exec -- make gen` |
| Format | `mise exec -- make format` |
| Check formatting | `mise exec -- make format-check` |
| Analyze | `mise exec -- make check` |
| App tests | `mise exec -- make test-unit` |
| App and package tests | `mise exec -- make test-unit-all` |
| Integration tests | `mise exec -- make test-integration DEVICE=<device-id>` |
| Full validation | `mise exec -- make precommit` |

Make is the public command surface. `tool/dart/ci.dart` owns generation, analysis, and test orchestration; shell scripts
handle platform-specific commands. Generators are workspace dependencies rather than mutable global installations.
Run `mise install` after changing tool versions and `make get` after changing package dependencies.

## Project structure

- `lib/src/common/`: HTTP client and middleware, controllers, database, localization, models, routing, and utilities.
- `lib/src/feature/`: authentication, initialization, settings, home, profile, developer tools, and bug reports.
- `packages/ui/`: shared widgets, theme, localization interface, shaders, and media helpers.
- `packages/ui/example/`: UI package example application.
- `test/`: application unit and widget tests.
- `android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/`: platform runners.
- `tool/`: build, generation, validation, and maintenance commands.
- `.github/`: CI and repository configuration.
- `.vscode/`: editor tasks and launch configurations.

## Documentation

- [Architecture](docs/architecture.md)
- [Navigation](docs/common/navigation.md)
- [Shared UI components](docs/common/ui-components.md)
- [Native UI performance harness](docs/ui-performance.md)
- [Conventions](docs/conventions.md)
- [Localization](docs/localization.md)
- [Toolchain and automation](docs/automation.md)
- [Dart rules](docs/rules/dart.md)
- [Flutter rules](docs/rules/flutter.md)
- [Testing rules](docs/rules/testing-preferences.md)
- [Agent instructions](AGENTS.md)

## Agent guidance

Shared skills live in [.agents/README.md](.agents/README.md). See [agent configuration](docs/agent-configuration.md) for Codex, Claude Code, hooks, and validation. The template version stays at `0.0.1+1`; downstream apps define their own release policy.
