---
name: flutter-network-debugging
description: "Debug Flutter HTTP and WebSocket traffic in development with proxy inspection, request replay, environment configuration, and credential-safe diagnostics."
---

# Flutter Network Debugging

Source: Adapted for this template; informed by the author's MITM proxy and full-duplex transport analyses.

## Trigger

Use when a Flutter client has an unexplained HTTP/WebSocket request, response, retry, handshake, proxy, serialization, or transport-timing problem that logs do not expose clearly.

## Workflow

- Reproduce only in a development or controlled test environment. Never proxy production traffic or capture real user tokens, cookies, personal data, or payment information.
- Configure the proxy through the existing environment mechanism, such as `--dart-define` or `--dart-define-from-file`; do not hardcode proxy hosts or credentials in source.
- Inspect request method, URL, headers, content type, body shape, status, timing, redirects, retry count, and response ordering. Redact secrets in saved captures and issue reports.
- For WebSockets, inspect handshake, authentication packet, message envelope, correlation/order, ping/pong, reconnect, duplicate delivery, and close code. A connected socket is not proof that the application protocol is healthy.
- Compare the observed wire shape with backend code and package contracts before changing parsing or transport selection.
- Use replay to isolate client rendering/parsing from server timing, but verify that replay preserves the failure condition and does not hide concurrency problems.

## Output

Report the environment, reproduction, redacted wire evidence, protocol phase, client/server ownership, and the smallest correction. State what the proxy cannot prove, especially provider delivery or production behavior.

## Validate

- Add or update typed contract tests for the discovered request/response shape.
- Test timeout, malformed body, unauthorized response, reconnect, cancellation, duplicate message, and out-of-order message behavior as applicable.
- Remove temporary proxy configuration before handoff and verify no secret entered source control.

## Related

- [`backend-auth-protocol-review`](../backend-auth-protocol-review/SKILL.md)
- [`flutter-repository-http-client`](../flutter-repository-http-client/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/architecture.md`](../../../docs/architecture.md)
