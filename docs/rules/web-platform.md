# Web Platform

Portable guidance adapted from the source application. Detailed SDK and project conventions remain in [Flutter rules](flutter.md), [Dart rules](dart.md), and [workflow rules](workflow.md).

## 1. Choose the surface before the language

Identify whether the target is Flutter Web, a browser page, PWA, or an embedded WebView. Do not assume equal capabilities.

## 2. Type at the boundary

Treat external JS, browser APIs, and payloads as untrusted. Validate nullable values, errors, and asynchronous results at the adapter boundary.

## 3. Discriminated unions for state

Use explicit state variants for loading, ready, permission denied, unsupported, and failed browser capabilities. TypeScript guidance applies only when a downstream project adds TypeScript.

## 4. Async work and cancellation

Guard stale callbacks, navigation, detached views, and disposed owners. Define cancellation and completion for JS interop and requests.

## 5. Browser capability matrix

Check secure contexts, permissions, user activation, browser support, storage quotas, file access, and fallback behavior. XFile bytes can work where filesystem paths cannot.

## 6. DOM rendering and embedded UI

Inspect CSP, origin boundaries, redirects, cookies, focus, scrolling, accessibility, and teardown. Keep WebView debugging limited to development.

## 7. Web performance

Measure startup, transfer size, renderer cost, interaction, and memory in representative browsers. Do not apply native-isolate or filesystem assumptions to web.

## 8. TypeScript review checklist

If TypeScript exists downstream, verify strict boundary types, async ownership, DOM lifecycle, and browser support. Do not add a JS framework to the Flutter template without a concrete need.
