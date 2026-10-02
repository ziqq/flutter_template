# Architecture Rules

This file contains project structure, layering, and reusable API design rules.
Flutter widget-specific patterns stay in [flutter.md](flutter.md).

Detailed backend boundary and protocol recovery rules are in
[backend-protocols.md](backend-protocols.md). Native-boundary guidance is in [rust.md](rust.md).


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


## Opinionated Architecture Policy

Prefer the smallest architecture that makes ownership, failure behavior, and testing explicit. template uses a
feature-first structure; it does not adopt a formal architecture template as a goal in itself.

- Do not add or expand usage of Hive, GetIt, or GetX in new code. Existing legacy usage may remain until the related
  feature is intentionally migrated; do not introduce new dependencies on top of it.
- Use explicit dependencies from the composition root, feature Scopes, `InheritedModel`, and the existing storage and
  controller contracts. Do not hide ownership in a service locator or a global registry.
- Do not introduce Clean Architecture layers such as `UseCase`, `Interactor`, `Presenter`, or parallel DTO/mapper
  hierarchies by default. In this repository they usually add indirection and duplicate models without creating a real
  boundary.
- Add an extra layer only when a concrete capability gap requires it, such as an independently owned protocol boundary,
  a separately testable policy with multiple consumers, or a lifecycle that cannot be expressed by the feature
  controller and repository contracts.
- Record the capability gap, rejected simpler alternatives, ownership, and acceptance criteria in the relevant feature
  document or architectural decision before introducing the layer.

The default flow is:

```text
widget -> controller/state -> repository -> transport or storage
```

Shared packages remain infrastructure. Feature-specific business logic stays in `lib/src/feature/<domain>/`.


## Project Structure
- Standard app entry point: `lib/main.dart`.
- Feature structure: `lib/src/feature/<domain>/{controller,data,model,widget}`.
- Shared cross-cutting code belongs in `lib/src/common`.
- Keep one cohesive responsibility per folder.


## Repository Conventions
- Repository interfaces are prefixed with `I`, for example `IProductRepository`.
- Network-backed concrete implementations use `<Name>Repository$Dio` or `<Name>Repository$HTTP` according to their
  production transport. Transport-neutral local repositories may keep `<Name>Repository`.
- Inject transport and persistence dependencies explicitly.
- A repository must not depend on another repository. Cross-repository orchestration belongs to a controller or the
  composition root; shared low-level persistence may be extracted behind a storage/data-source interface.
- Preserve `{@template ...}` and `{@macro ...}` documentation macros.
- Fake repositories should:
  - be annotated with `@visibleForTesting`
  - use the `$Fake` suffix
  - remain simple and deterministic
  - prefer response payload constants that are copied or assembled from `test/src/unit_test/src/feature/<domain>/data/fixtures/*.json`
  - stay structurally aligned with the repository test fixtures so fake data and mocked transport responses drift together, not apart
  - use `SaleRepository$Fake` as the reference shape for larger fake repositories with multiple backend-like responses


## Data Flow
- Define explicit model classes for all meaningful domain data.
- Abstract transport and persistence behind repositories or services.
- Keep parsing and serialization close to the model or transport boundary, not in widgets.
- Avoid cross-feature data access through widget-tree reacharound patterns. Use constructor DI, feature scope accessors, or shared dependencies instead.
