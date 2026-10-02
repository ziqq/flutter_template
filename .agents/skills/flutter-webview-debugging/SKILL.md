---
name: flutter-webview-debugging
description: "Debug Flutter WebView and Custom Tabs content, JavaScript errors, network requests, storage, and platform-specific inspection behavior."
---

# Flutter WebView Debugging

Source: Adapted for this template; informed by the author's WebView and Custom Tabs debugging analysis.

## Trigger

Use when an embedded web page, Custom Tab, JavaScript bridge, redirect, cookie, storage, network request, or platform WebView behaves differently from a desktop browser.

## Review

- Identify the platform, WebView implementation/version, URL/redirect chain, JavaScript requirement, storage/cookie policy, user-agent, and native bridge contract.
- Use platform inspection tools such as Chrome DevTools device inspection where supported, but do not infer iOS behavior from Android inspection or desktop Chrome.
- Inspect console errors, network requests, status/content type, CSP/CORS, redirects, cookie/storage state, viewport, and lifecycle events together.
- Verify deep-link and authentication redirects with the actual app scheme, browser handoff, user gesture, and cancellation path.
- Keep secrets and session tokens out of console logs, screenshots, proxy captures, and bug reports.
- Treat WebView and Custom Tabs as different ownership models: the app may control one, while the browser controls the other. Document what can be tested or changed in each.

## Output

Produce a platform matrix with observed behavior, inspection evidence, native/web ownership, fallback, and unresolved provider or browser assumptions.

## Validate

- Reproduce on every affected platform and at least one release-like build when lifecycle or redirect behavior matters.
- Test cold start, app background/foreground, back navigation, failed load, offline, redirect cancellation, cookie expiry, and bridge errors.
- Pair network findings with `flutter-network-debugging` and authentication findings with `backend-auth-protocol-review`.

## Related

- [`flutter-network-debugging`](../flutter-network-debugging/SKILL.md)
- [`backend-auth-protocol-review`](../backend-auth-protocol-review/SKILL.md)
- [`web-capability-review`](../web-capability-review/SKILL.md)
- [`flutter-widget-lifecycle-review`](../flutter-widget-lifecycle-review/SKILL.md)
