---
name: repository-http-client
description: "Use when: creating, migrating, testing, or reviewing AppOrOrgName repositories that use ApiClient$HTTP, ApiClient$Dio, JSON parsing, typed API errors, or packages/api transport boundaries."
---

# Repository HTTP Client

Source: AppOrOrgName-native; derived from `packages/api/README.md`, `packages/api/docs/architecture.md`, `docs/rules/architecture.md`, `docs/rules/models.md`, and existing repositories.

Use this skill for data-layer work that touches API clients, repository contracts, transport migration, JSON parsing, typed exceptions, or fake repositories.

## First Sources To Inspect

- `packages/api/README.md` for public transport behavior.
- `packages/api/docs/architecture.md` for ownership boundaries and runtime middleware order.
- Existing repositories in the same feature under `lib/src/feature/<domain>/data/`.
- Models in `lib/src/feature/<domain>/model/` and `docs/rules/models.md` for parsing rules.
- Repository tests and fixtures under `test/unit_test/src/feature/<domain>/data/`.

## Transport Choice

- Prefer `ApiClient$HTTP` for new repositories and repositories being actively migrated.
- Keep `ApiClient` / `ApiClient$Dio` only for legacy repositories that still depend on the raw `Future<Object?>` contract.
- Before migrating to `ApiClient$HTTP`, confirm the endpoint returns `application/json` and a top-level JSON object.
- Do not migrate endpoints that return files, binary data, plain text, empty non-JSON bodies, or other special formats until the backend or transport contract is adapted.
- Preserve response metadata when middleware, retries, auth replay, or status inspection depends on it.

## Repository Shape

- Define an `I<Name>Repository` abstract interface for meaningful data boundaries.
- Use `<Name>Repository` for the concrete implementation.
- Inject clients and persistence dependencies explicitly through constructors.
- Keep parsing and serialization close to the model or repository boundary, never in widgets.
- Preserve `{@template ...}` and `{@macro ...}` docs when editing existing repositories.
- Add or update `<Name>Repository$Fake` with `@visibleForTesting` when app fake mode or widget/controller tests need deterministic data.

## JSON And Error Rules

- Do not use `dynamic` in parsing. Use `Object?`, typed aliases such as `JSON`, and pattern matching with `switch`.
- Invalid payload shape should throw `FormatException` with enough context to diagnose the bad response.
- Parse enums through explicit `fromValue` switches; do not use `name` or `values.byName` for backend values.
- Treat empty objects, missing payloads, and unexpected arrays as explicit cases, not accidental casts.
- Let `ApiClient$HTTP` normalize transport errors into typed `ApiException` variants; repositories should only translate errors when they add domain meaning.
- Keep backend `errors.code` and `errors.message` intact when using HTTP error envelopes.

## Retry, Connectivity, And Middleware

- Connectivity means general internet reachability, not backend health.
- Do not report backend `5xx` as global offline state.
- Default retry behavior is conservative: transport failures, `408`, `429`, and selected `5xx` statuses are retryable; `401`, `403`, client validation, and business `4xx` are not.
- App-specific authentication, metadata, Sentry scope wiring, and token refresh logic stay outside `packages/api`.
- Transport-safe primitives such as retry, logging, timeout, connectivity, and deduplication belong in `packages/api` only when they do not depend on app session or feature models.

## Tests And Fixtures

- Add repository unit tests for success, invalid payload, empty response, and typed error mapping when behavior changes.
- Keep fake repositories aligned with repository JSON fixtures.
- Prefer focused transport/client mocks over broad app-level widget tests for parsing and repository behavior.
- When changing `packages/api`, run that package's tests and escalate to `make test-unit-all` if app repositories are affected.

## Review Checklist

- Is `ApiClient$HTTP` used only with JSON object endpoints?
- Is the repository interface stable and caller-oriented?
- Are parsing failures loud and typed with `FormatException`?
- Are transport errors preserved instead of flattened into generic messages?
- Are fakes, fixtures, and repository tests updated together?
- Does the change respect package ownership boundaries?

## Related

- [`verify-changes`](../verify-changes/SKILL.md)
- [`review-pr`](../review-pr/SKILL.md)
- [`docs/rules/architecture.md`](../../../docs/rules/architecture.md)
- [`docs/rules/models.md`](../../../docs/rules/models.md)
- [`packages/api/README.md`](../../../packages/api/README.md)
- [`packages/api/docs/architecture.md`](../../../packages/api/docs/architecture.md)
