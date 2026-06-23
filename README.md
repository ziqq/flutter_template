# Flutter template by [ziqq](https://github.com/ziqq), concept taken from [Plague Fox](https://github.com/PlugFox/control)


## Getting started

### 1. [Install Flutter](https://docs.flutter.dev/install) and [FVM](https://fvm.app/documentation/getting-started/installation) or [mise](https://mise.jdx.dev/demo.html)

### 2. Clone the repository and run the app
To run the desired project either use the launch configuration in VSCode/Android Studio or use one of the following CLI flows. The `fvm` flow is the source of truth for flavor-specific SDK selection. The `mise` flow is suitable for local development with the project-level `stable` SDK.

#### Using `fvm`:

```sh
git clone https://github.com/TetradkaAI/tetradka_app.git
cd tetradka_app
fvm use development
fvm flutter pub get
fvm flutter run --flavor dev --dart-define-from-file=config/development.json # or run from tasks in VSCode (debug:dev or etc.)
```

#### Using `mise`:

```sh
git clone https://github.com/TetradkaAI/tetradka_app.git
cd tetradka_app
mise install
flutter pub get
flutter run --flavor dev --dart-define-from-file=config/development.json # or run from tasks in VSCode (debug:dev or etc.)
```

### How to work with fvm
The repository keeps the Flutter SDK mapping in [`.fvmrc`](.fvmrc):

- `development` -> `stable`
- `production` -> `3.44.2`
- `staging` -> `3.44.2`

Use `fvm` when you need the exact SDK configured for a flavor:

```sh
fvm use development
fvm flutter pub get
fvm flutter run --flavor dev --dart-define-from-file=config/development.json
```

For staging or production builds switch to the corresponding flavor first:

```sh
fvm use staging
fvm flutter --version
```

### How to work with mise
The repository also supports `mise` for local development. The project-level configuration is stored in [`mise.toml`](mise.toml):

```toml
[tools]
flutter = "stable"
java = "temurin-17"
```

Install and activate `mise`:

```sh
brew install mise
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

Install the tools declared in [`mise.toml`](mise.toml):

```sh
mise install
mise current
flutter --version
dart --version
```

If the shell activation has not been applied yet, run commands through `mise exec`:

```sh
mise exec -- flutter doctor
mise exec -- flutter pub get
mise exec -- flutter run --flavor dev --dart-define-from-file=config/development.json
```

After activation you can use Flutter and Dart directly without the `fvm` prefix:

```sh
flutter pub get
flutter test
dart run tool/dart/ci.dart test-app
```

Recommended workflow:

- Use `mise` for day-to-day local development with the `stable` SDK from [`mise.toml`](mise.toml).
- Use `fvm` when you must match the exact flavor-specific SDK from [`.fvmrc`](.fvmrc), especially for `staging` and `production`.
- Keep `make` as the stable CLI entrypoint. The toolchain runner already prefers `fvm` and falls back to system `flutter` and `dart` when `fvm` is unavailable.

### 3. Replace project name, description and organization:

```sh
dart run tool/dart/rename_project.dart --name="project" --organization="tld.domain" --description="My project description"
```

### 4. Search and replace `AppOrOrgName` with your project name in all files, including hidden files.

### 5. Search and replace `https://github.com/user_or_org_name/flutter_template_name` with your repository URL in all files, including hidden files.


## Documentation

- Product goals: [`docs/goals.md`](docs/goals.md)
- Milestones and acceptance criteria: [`docs/milestones.md`](docs/milestones.md)
- Architectural memory / decisions: [`docs/decisions.md`](docs/decisions.md)
- Architecture: [`docs/architecture.md`](docs/architecture.md)
- Shared transport-cache: [`docs/common/cache.md`](docs/common/cache.md)
- API package architecture: [`packages/api/README.md`](packages/api/README.md), [`packages/api/docs/architecture.md`](packages/api/docs/architecture.md)
- Conventions (generated code, icons rules, prohibitions): [`docs/conventions.md`](docs/conventions.md)
- Localization (Google Sheets → generation task): [`docs/localization.md`](docs/localization.md)
- Integrations: [`docs/integrations.md`](docs/integrations.md)
- Deployment / CI/CD: [`docs/deployment.md`](docs/deployment.md)
- Workspace automation plan: [`docs/automation.md`](docs/automation.md)
- Feature memory examples: [`docs/features/client.md`](docs/features/client.md), [`docs/features/visit.md`](docs/features/visit.md)
- AI rules (Copilot): [`.github/copilot-instructions.md`](.github/copilot-instructions.md)
- How to write code: [`docs/rules/flutter.md`](docs/rules/flutter.md)
- VS Code tasks (authoritative generators entrypoint): [`.vscode/tasks.json`](.vscode/tasks.json)


## Key commands

| Action | Command |
|---|---|
| Dependencies | `make get` |
| Code generation | `make gen` |
| Formatting | `make format` |
| Analysis | `make check` |
| Tests (app + packages) | `make test-unit-all` |
| Integration tests | `make test-integration DEVICE=<device-id>` |
| Full check (CI) | `make precommit` |

Local tooling contract:
Use `make` as the stable entrypoint for CLI commands and VS Code tasks. Where the workflow is supported by `tool/dart/ci.dart`, the Makefile delegates to that runner, and `ci.dart` automatically prefers `fvm` but falls back to system `dart` / `flutter` / `fluttergen` when `fvm` is not installed.


## Project Structure

```
.github/
├─ actions/
│  ├─ setup-flutter/
│  └─ action.yaml                 # GitHub Action to setup Flutter
└─ workflows/
   ├─ release-message.yaml        # Release message workflow
   ├─ issue-labeler.yaml          # Issue labeler workflow
   ├─ build-dev.yaml              # Development build workflow
   ├─ build-prod.yaml             # Production build workflow
   ├─ ci.yaml                     # Checkout workflow
   └─ ci-cd.yaml                  # CI/CD workflow configuration

.vscode/
├─ launch.json                    # VSCode launch configurations
├─ settings.json                  # VSCode settings for the project
├─ extensions.json                # Recommended VSCode extensions
└─ tasks.json                     # VSCode tasks for build and run

.well-known/
├─ apple-app-site-association     # App links for iOS app association
└─ assetlinks.json                # Asset links for Android app association

assets
├─ app                            # App assets (launcher icons, splash screens, etc.)
├─ icons                          # Icons of the app
├─ images                         # Any images
└─ rive                           # [Rive](https://pub.dev/packages/rive) assets

config/
├─ development.json               # Development environment configuration
├─ production.json                # Production environment configuration
└─ staging.json                   # Staging environment configuration

integration_test/                 # Unit & Widget integration tests

lib
├─ main.dart                      # Main entry point
├─ ui.dart                        # Design system demonstration app
└─ src
   ├─ common                      # Core utilities and shared code
   │  ├─ constants                # App shared constants
   │  ├─ controller               # Base app controller
   │  ├─ database                 # App database (sqlight)
   │  ├─ localization             # **Deprecated** app localization, use package/localization insted
   │  ├─ models                   # App shared data models
   │  ├─ router                   # App navigation and routing
   │  │  ├─ app_pages.dart
   │  │  └─ app_navigator.dart
   │  ├─ util                     # App utils
   │  │  ├─ enum                  # App shared enumirations
   │  │  ├─ exception             # App shared exceptions
   │  │  ├─ extension             # App shared extensions
   │  │  ├─ mixin                 # App shared mixins
   │  │  ├─ platform              # Platform specific utils
   │  │  ├─ analytics.dart        # Analytics integration
   │  │  └─ ...other utils
   │  └─ widget                   # App common widgets
   │
   └─ feature                     # App feature's
     └─ example_future
         ├─ controller            # Controllers and states
         ├─ data                  # Future data / repositories and etc.
         ├─ model                 # Future data entities and models
         └─ widget                # Future widge's

packages
├─ localization                   # App localization package, generated from Google Sheets
└─ ui                             # Shared UI Components, Widgets, Fonts, Colors and Theme

test/                             # Unit & Widget tests
```


## License

See [`LICENSE`](LICENSE).