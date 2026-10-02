---
name: flutter-repository-http-client
description: "Create, migrate, test, or review template repositories using ApiClient$HTTP, JSON parsing, typed API exceptions, connectivity middleware, response helpers, fakes, and lib/src/common/api_client ownership boundaries."
---

# Repository HTTP Client

Source: Adapted for this template; derived from `lib/src/common/api_client` documentation, architecture/model rules, and existing repositories.

## Inspect First

- Read `docs/architecture.md` and `docs/architecture.md`.
- Inspect the endpoint contract in server documentation and backend code.
- Inspect repositories, models, tests, fakes, and fixtures in the same feature.

## Choose The Transport

Prefer `ApiClient$HTTP` for new or migrated endpoints only when successful responses are JSON objects with an appropriate JSON content type.

Use a dedicated raw `http.Client` or `FileUtil` path for files, bytes, text, empty non-JSON responses, and streaming. Inspect the actual response contract before using JSON-object middleware; this template has no Dio client.

## Repository Contract

- Expose a caller-oriented `IFooRepository` interface and keep transport details private.
- Implement deterministic `FooRepository$Fake` behavior for tests where required.
- Parse `Object?` through typed patterns and explicit switches; never use `dynamic`.
- Throw `FormatException` for malformed payloads and preserve typed transport/API exceptions.
- Keep auth, retry, connectivity, replay, metadata, and error classification in the package layer that owns them.
- Do not convert backend `5xx` failures into a global offline state.
- Avoid hidden retries for non-idempotent mutations unless replay safety is proven.

## Tests

Cover successful parsing, malformed shape, typed API errors, auth/retry behavior when relevant, connectivity classification, and fake/fixture alignment. Verify empty or special-format responses explicitly when the endpoint contract allows them.

## Related

- [`flutter-feature-module`](../flutter-feature-module/SKILL.md)
- [`project-pr-review`](../project-pr-review/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/architecture.md`](../../../docs/architecture.md)
- [`docs/architecture.md`](../../../docs/architecture.md)
- [`docs/rules/models.md`](../../../docs/rules/models.md)
