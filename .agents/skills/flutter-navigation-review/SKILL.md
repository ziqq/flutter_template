---
name: flutter-navigation-review
description: "Review Flutter navigation and routing choices, deep links, nested navigators, back behavior, restoration, and route-state ownership."
---

# Flutter Navigation Review

Source: Adapted for this template; informed by the author's Flutter navigation and Octopus discussions.

## Trigger

Use when adding or changing routes, nested navigation, deep links, browser history, dialogs/sheets as routes, restoration, or a navigation package.

## Review

- Separate the router's route/state parsing responsibility from the navigator's stack and transition responsibility.
- Write the route contract first: path/URI shape, typed parameters, query data, authentication gate, restoration behavior, unknown-route behavior, and platform back semantics.
- Identify who owns navigation commands. Widgets may request navigation; controllers and repositories must not reach into a global navigator or hidden route registry.
- Check nested stacks, tab switching, modal routes, replacement/pop behavior, duplicate taps, deep-link cold start, and state restoration.
- When using Navigator restoration, define both the navigator restoration scope and stable `MaterialPage.restorationId`
  values, then test process-death restoration from the real app entry point.
- Preserve template's current route conventions in `lib/src/common/router/` and inspect existing pages before introducing a new abstraction.
- Audit a package's source, tests, current Flutter compatibility, generated code, and failure behavior before adopting it. Do not adopt Octopus or another router merely because it is discussed in an article.

## Output

Provide a route/state diagram in prose, ownership boundaries, platform behavior, rejected alternatives, migration risk, and focused validation scenarios.

## Validate

- Test initial route, authenticated/unauthenticated redirect, deep link, unknown route, nested stack, back navigation, duplicate navigation, restoration, and disposal of route-owned resources as applicable.
- Use `dart-package-audit` before adding a navigation dependency.
- Run focused widget tests and the smallest platform/integration check that exercises the route contract.

## Related

- [`dart-package-audit`](../dart-package-audit/SKILL.md)
- [`flutter-widget-lifecycle-review`](../flutter-widget-lifecycle-review/SKILL.md)
- [`web-capability-review`](../web-capability-review/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`lib/src/common/router/`](../../../lib/src/common/router/)
