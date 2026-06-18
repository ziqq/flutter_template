# Architecture Rules

This file contains project structure, layering, and reusable API design rules.
Flutter widget-specific patterns stay in [flutter.md](flutter.md).


## API Design Principles
- Design APIs from the perspective of the caller.
- Prefer APIs that are hard to misuse and easy to read at call sites.
- Documentation is part of the API contract.
- Choose names that communicate domain meaning, not implementation details.
- Prefer explicit named parameters over ambiguous positional parameters.


## Application Architecture
- Aim for clear separation of concerns similar to MVC or MVVM.
- Keep these responsibilities separate:
  - **Model:** immutable domain and transport-safe entities.
  - **Data:** repositories, clients, adapters, and persistence boundaries.
  - **Controller:** orchestration, mutation flow, async handling, and UI-facing state.
  - **Widget:** rendering and user interaction.
- For larger domains, organize code by feature rather than by technical layer alone.


## Project Structure
- Standard app entry point: `lib/main.dart`.
- Feature structure: `lib/src/feature/<domain>/{controller,data,model,widget}`.
- Shared cross-cutting code belongs in `lib/src/common`.
- Keep one cohesive responsibility per folder.


## Repository Conventions
- Repository interfaces are prefixed with `I`, for example `IProductRepository`.
- Concrete implementations use `<Name>Repository`.
- Inject transport and persistence dependencies explicitly.
- Preserve `{@template ...}` and `{@macro ...}` documentation macros.
- Fake repositories should:
  - be annotated with `@visibleForTesting`
  - use the `$Fake` suffix
  - remain simple and deterministic
  - prefer response payload constants that are copied or assembled from `test/unit_test/src/feature/<domain>/data/fixtures/*.json`
  - stay structurally aligned with the repository test fixtures so fake data and mocked transport responses drift together, not apart
  - use `SaleRepository$Fake` as the reference shape for larger fake repositories with multiple backend-like responses


## Data Flow
- Define explicit model classes for all meaningful domain data.
- Abstract transport and persistence behind repositories or services.
- Keep parsing and serialization close to the model or transport boundary, not in widgets.
- Avoid cross-feature data access through widget-tree reacharound patterns. Use constructor DI, feature scope accessors, or shared dependencies instead.