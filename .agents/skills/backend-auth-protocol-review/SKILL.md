---
name: backend-auth-protocol-review
description: "Review Flutter and backend authentication, JWT/OAuth flows, session ownership, ping/pong health protocols, RPC contracts, and endpoint error behavior."
---

# Authentication And Protocol Review

Source: Adapted for this template; see the [backend and protocol rules](../../../docs/rules/backend-protocols.md)
and current repository contracts. Treat provider behavior and security details as claims to verify against authoritative
documentation.

## Trigger

Use when a task changes login, token validation, OAuth2, JWT, session storage, API contracts, health checks, ping/pong, RPC, WebSocket behavior, retries, or server/client protocol boundaries.

## Authentication

- Identify whether a token is an identity token, access token, refresh token, or application session token; do not treat their claims or audiences as interchangeable.
- Validate issuer, audience, expiry, signature algorithm, key material, nonce/state, and provider-specific claims on the server using the provider's current documentation and code contract.
- Exchange a provider token for an application-owned session only after server-side validation. Never trust client-decoded claims as authorization.
- Keep app session persistence behind the project's `ISessionStorage` contract; do not hide auth ownership in a generic Scope, controller registry, or controller-to-controller coordination.
- Never log raw access, refresh, identity, or session tokens.
- Remember that a JWT is signed, not encrypted: claims are readable by anyone who receives the token. Keep secrets and sensitive data out of claims unless the contract explicitly requires them and the exposure is acceptable.
- Do not authorize from client-side decoding. The server must verify signature, issuer, audience, expiry, algorithm, and provider/application binding with current key material.
- For OAuth2, state which actor needs delegated authority and which redirect/callback owns the exchange. Do not add OAuth2 when a signed provider token is sufficient for the stated flow.
- Refresh a `401` only when it represents an expired/invalid access token and a refresh credential exists for the same
  session identity; retry the original request at most once. Treat `403` as forbidden and do not refresh blindly.
- Keep OAuth2 delegated authorization distinct from OIDC identity. For Google ID tokens, verify signature, `aud`, `iss`,
  and `exp` server-side; use `hd` only when domain membership is part of the application contract.

## Protocols

- Define message shape, correlation, ordering, timeout, cancellation, retry, duplicate delivery, and error behavior before implementing ping/pong or RPC.
- Keep health checks distinct from backend business availability when the product has a separate connectivity model.
- Keep client and server contracts typed and versionable. Verify response content type and body shape before selecting or migrating a transport client.
- For WebSocket or event protocols, document reconnect and replay behavior; do not equate a visible browser Network panel with the complete application protocol.
- Treat a successful WebSocket handshake as transport readiness only. Separately verify authentication, message envelope, correlation, ordering, heartbeat, close codes, reconnect, duplicate delivery, and stale-session behavior.

## Output

Report the trust boundary, token/session owner, claims validated, protocol state machine, failure modes, replay/duplicate risks, and evidence source. Mark unverified provider or platform assumptions explicitly.

## Validate

- Read the relevant backend contract and authentication feature docs before changing code.
- Add tests for invalid signature, wrong audience/issuer, expired token, missing claims, callback failure, timeout, duplicate request, and retry behavior as applicable.
- Use `mise exec -- make format`, focused tests, and the smallest package/app check that exercises the boundary.

## Related

- [`flutter-repository-http-client`](../flutter-repository-http-client/SKILL.md)
- [`project-pr-review`](../project-pr-review/SKILL.md)
- [`project-verify-changes`](../project-verify-changes/SKILL.md)
- [`docs/architecture.md`](../../../docs/architecture.md)
- [`AGENTS.md`](../../../AGENTS.md)
