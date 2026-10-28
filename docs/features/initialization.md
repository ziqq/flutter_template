# Initialization

`lib/src/feature/initialization/data/initialize_dependencies.dart` owns the ordered startup steps and builds
`Dependencies`. It connects storage, restores settings, applies analytics consent, initializes clients/controllers,
and prepares navigation and logging. Preserve dependency order when adding a step.

Each executed step records its name, execution index, and Stopwatch duration in an immutable `InitializationStats`
snapshot. The total sums measured step execution time; progress callbacks and pre-start work are outside this total.
The `finally` block records a failing step before startup propagates the original error and stack trace.

The developer statistics screen reads this snapshot. It does not restart initialization or fetch remote metrics.
Tests cover immutable snapshots, totals, zero duration, stable sorting, and empty/filled diagnostic views.

This timing instrumentation does not implement rollback or disposal of partially initialized dependencies.
A downstream application must define that lifecycle contract before introducing resources that need rollback.

## Resource ownership

Initialization registers cleanup beside each resource acquisition through the instance-owned asynchronous
`Disposable` chain. Raw HTTP clients, logging subscriptions, and pending log writes stay local to initialization;
they are not dependency-container fields. Feature scopes borrow application resources; unmounting `ConnectivityScope`
does not dispose the application-owned service. `FakeDependencies` inherits the same container.

After unmounting the widget tree, call `$disposeApp(dependencies)` for a fully initialized graph. Cleanup runs once in
reverse registration order, awaits asynchronous actions, and continues after failures. Logging subscriptions stop
before pending writes are drained, and the database closes last. The first cleanup error is rethrown with its original
stack trace.

This teardown is terminal. It does not implement partial-startup rollback or application restart.

## HTTP configuration

HTTP initialization selects its local API URL once. The saved `api_base_url` override applies only in development when
`URL_FROM_LOCAL_STORAGE` is enabled; invalid override schemes fall back to `Config.apiBaseUrl`. Application requests,
authorization replay, and token refresh share that selected URL. Later preferences changes take effect on a new launch.

`API_REQUEST_TIMEOUT` is a positive deadline in milliseconds, defaulting to `30000`. Startup rejects zero and negative
values. The HTTP timeout middleware applies one deadline to each retry attempt, including response headers and body;
the refresh middleware has its own deadline for each refresh attempt. Expiry aborts that request and leaves the shared
client open. Caller cancellation, request-specific timeout overrides, and the existing retry/replay rules are preserved.
The unused `API_CONNECT_TIMEOUT` and `API_RECEIVE_TIMEOUT` settings are replaced by this single deadline.
