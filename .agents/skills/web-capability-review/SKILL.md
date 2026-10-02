---
name: web-capability-review
description: "Review Flutter Web, JavaScript/TypeScript, PWA, WebView, TWA, browser API support, and native capability trade-offs before choosing or changing a platform strategy."
---

# Web Platform Capability Review

Source: Adapted for this template; see the [TypeScript and Web rules](../../../docs/rules/web-platform.md) and current platform contracts.

## Trigger

Use when a feature targets Flutter Web, a browser, PWA, WebView/TWA, JavaScript/TypeScript, desktop, Android, or iOS, especially when platform capability or distribution is part of the decision.

## Review

- Start with required capabilities: background work, push, filesystem, payments, native authentication, multiple windows, offline behavior, deep links, SEO, bundle size, and update policy.
- Compare Flutter Web, JS/TS, PWA, WebView/TWA, and native implementations against those capabilities rather than framework preference.
- Verify browser APIs against current support tables and provide a fallback for unsupported browsers. SharedWorker, popup, tab, storage, and WebSocket behavior are platform facts, not assumptions.
- Treat Safari/iOS user-gesture restrictions, browser state loss, and WebView plugin/update limitations as explicit failure modes.
- Distinguish a web app wrapped in a native shell from an app with true native capabilities. Document which logic remains remotely changeable and which changes require store review.
- For Flutter Web, inspect renderer, bundle/startup cost, responsive constraints, browser history, and whether the product actually needs a web application or only a cross-platform surface.

## Output

Produce a capability matrix with target platforms, required behavior, supported path, fallback, distribution constraint, and verification source. Mark time-sensitive claims for current official documentation or browser-support verification.

## Related

- [`flutter-adaptive-layout-review`](../flutter-adaptive-layout-review/SKILL.md)
- [`backend-auth-protocol-review`](../backend-auth-protocol-review/SKILL.md)
- [`dart-package-audit`](../dart-package-audit/SKILL.md)
- [`docs/rules/flutter.md`](../../../docs/rules/flutter.md)
