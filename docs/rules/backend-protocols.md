# Backend and Persistence Protocols

Portable guidance adapted from the source application. Detailed SDK and project conventions remain in [Flutter rules](flutter.md), [Dart rules](dart.md), and [workflow rules](workflow.md).

## 1. Define the wire contract

Inspect server code and documentation before changing an endpoint. Specify method, path, auth, status codes, content type, payload, nullable fields, and failure behavior. The template does not imply a downstream backend contract.

## 2. Authentication recovery

Bound refresh and replay attempts. Coordinate concurrent refresh, cancellation, logout, and credential replacement. Never replay unsafe mutations without proven idempotency.

## 3. HTTP and content types

ApiClient$HTTP owns JSON-object responses. FileUtil and raw HTTP handle bytes and other formats. Check empty bodies, malformed JSON, non-object JSON, redirects, and content-type errors explicitly.

## 4. Idempotency and ordering

Specify mutation identity, duplicate behavior, retry limits, replayable bodies, and server ordering. An automatic retry does not make an operation idempotent.

## 5. Persistence and cache ownership

Define schema version, migration owner, user namespace, TTL, serialization, invalidation, partial writes, corruption, and recovery. Do not publish success before persistence completes.

## 6. Time pagination and money

Define UTC versus local dates, precision, rounding, pagination stability, cursor invalidation, and duplicate handling. Preserve domain distinctions rather than guessing from field names.

## 7. Observability and privacy

Sanitize sensitive headers, URL query values, credentials, user content, and signed links before logging. Keep analytics consent effective at collection and dispatch boundaries.

## 8. Protocol review checklist

Test malformed responses, auth races, replay, cancellation, partial persistence, and backend failures. Distinguish transport failure from actual offline connectivity.
