---
name: data-local-storage-review
description: "Review Flutter local persistence and cache choices for ownership, typed time values, migrations, corruption recovery, portability, memory use, and testability."
---

# Local Storage Review

Source: Adapted for this template; see the [persistence and cache rules](../../../docs/rules/backend-protocols.md#5-persistence-and-cache-ownership),
the [architecture contract](../../../docs/architecture.md), and repository persistence rules.

## Trigger

Use when a feature adds local storage, a cache, SQLite, a key-value database, offline data, timestamps, migrations, or a local/server persistence decision.

## Review

- First classify the data as server-owned state, structured local state, small preferences, a derived cache, or ephemeral memory.
- Prefer the repository's existing `Database` for structured relational state and `SharedPreferencesAsync` for small key-value state before adding another store.
- Store time with a typed, queryable representation appropriate to the database contract; do not default to formatted display strings for comparisons or ranges.
- Require migrations for schema/model changes and define behavior for partial writes, corrupt files, missing records, version mismatch, and reset/recovery.
- Check memory residency, indexing, query shape, serialization cost, multi-isolate/platform behavior, and whether a cache can be rebuilt safely.
- Keep persistence ownership in the data layer. Controllers and widgets should not manipulate database handles directly.
- Treat a package's test count, benchmark, and support claims as evidence to inspect, not as proof.

## Output

Report ownership, schema/time representation, migration path, recovery behavior, cache invalidation, performance risk, and the smallest focused test or failure simulation needed.

## Related

- [`flutter-repository-http-client`](../flutter-repository-http-client/SKILL.md)
- [`dart-package-audit`](../dart-package-audit/SKILL.md)
- [`flutter-state-layer-review`](../flutter-state-layer-review/SKILL.md)
- [`docs/architecture.md`](../../../docs/architecture.md)
