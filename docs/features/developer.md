# Developer Tools

`DeveloperButton` opens `DeveloperPage` through the nearest `AppNavigator`. The app-owned pages are declared in
`lib/src/common/router/app_pages.dart`: developer settings, application information, log viewer, and startup statistics.
Only `/developer` is accepted by the external parser; internal diagnostic pages do not become deep links implicitly.

## Available tools

- Persist debug, development, beta, experimental, haptic, and glass-preview flags.
- Inspect application metadata and the current user ID. No authentication token is displayed.
- Preview the existing status indicator, snackbars, bug-report dialog, and confirmation dialog.
- Change theme and analytics sending preferences.
- Search current logs, inspect details, clear stored logs, or export them through the existing XFile report path.
- Clear the app key/value table and refresh its in-memory view; unrelated preference storage is preserved.
- Sign out of the current application session after confirmation.

Account selection, subscriptions, all-device session revocation, and server push-token updates are not part of this
template. Firebase token inspection is available only after Firebase initialization. Logs may contain sensitive data;
sharing or sending a report is an explicit user action, not an automatic diagnostic upload.

## Startup statistics

Initialization measures every executed step using Stopwatch and stores an immutable `InitializationStats` snapshot
in Dependencies. The total is the sum of step durations, not the entire process launch time. The view orders steps
by duration with execution index as a stable tie-breaker, displays percentages and a heat map, and uses `UIPieChart`
for interactive segments. Steps shorter than one millisecond remain in the list but are omitted from the chart.
Empty snapshots have an explicit empty state. Partial snapshots include a failed step, although startup failure
handling does not open this screen automatically.

## UI compatibility

The migrated screens use the template UI kit and SDK controls. Existing `PieChart` callers remain unchanged;
`UIPieChart` is an additional chart used by diagnostics. The glass wrapper uses the existing PressTransition and
Flutter BackdropFilter; it is an optional preview, not a platform-native implementation.

## Validation

Tests cover typed navigation, analytics setting failure, state-aspect notifications, log filtering, empty/filled
startup views, snapshot immutability, stable ordering, and chart interaction. Run `mise exec -- make test-unit-all`.
