# ADR-012 — API Authentication Model

- **Status:** Accepted (implemented in Sprint 003, PR #38, commit `a5ae82c`,
  2026-07-16; this ADR documents that decision retroactively — it records
  an existing, unchanged design, not a new one)
- **Date:** 2026-07-26 (ADR written); underlying decision dated 2026-07-16

## Context

STARCORE is a modular monolith aimed at homelab/self-hosted deployments,
typically operated by one person or a small trusted team, not a
multi-tenant SaaS with per-user accounts. `ADR-003` (rate limiting)
mentions the existing authentication model in passing as context, but no
ADR captured the authentication decision itself: a single static shared
secret, compared in constant time, checked on every protected route. This
ADR closes that gap so the model is on record rather than only inferable
from `packages/core/main.py`.

## Decision

A single `STARCORE_API_KEY` value, supplied via the `X-API-Key` request
header, protects every route except `/`, `/health`, `/ui`, and the mounted
`/ui/assets` static files. `verify_api_key()` (`packages/core/main.py`):

- **Fails closed:** if `STARCORE_API_KEY` is not configured on the server,
  every protected route returns `503`, never falls through to "no auth
  required." An unconfigured server is inaccessible, not silently open.
- **Constant-time comparison:** the supplied header value is compared to
  the configured key via `hmac.compare_digest`, not `==`/`!=`, so a
  network-positioned attacker cannot use response-timing differences to
  guess the key byte-by-byte. `hmac.compare_digest` is safe to use here
  even though the attacker-controlled value is the *left* operand, because
  it always compares the full length of both inputs regardless of where
  they first differ.
- **No per-user identity, no key rotation mechanism, no scopes.** The key
  is a single shared secret for the whole deployment; anyone with it has
  full access to every protected route.

## Alternatives considered

1. **Per-user API keys / OAuth2 / session-based auth:** rejected as
   disproportionate to the deployment target — a homelab operator does not
   need multi-user access control for their own infrastructure
   orchestrator, and adding an identity system would be exactly the kind
   of speculative infrastructure the project avoids elsewhere.
2. **mTLS or IP allowlisting instead of an application-level key:** rejected
   because it pushes the trust boundary into deployment-specific network
   configuration STARCORE cannot verify or test, whereas a header-based key
   works identically whether STARCORE runs bare, in Docker, or behind a
   reverse proxy.
3. **Naive string equality (`==`/`!=`) for the key check:** rejected (and
   fixed, PR #38) once identified as a timing side-channel — `==` on
   Python `str` short-circuits at the first differing byte, which is
   observable as a (small but real) timing signal over many requests.

## Consequences

- Simple to configure (`.env` / `STARCORE_API_KEY`) and simple to reason
  about: one secret, compared safely, checked everywhere it needs to be.
- No user-level audit trail of *who* made an authenticated request — only
  that *a* holder of the key did. Acceptable for the current
  single-operator/small-team target; would need revisiting before any
  multi-tenant use.
- Key rotation is a manual operational step (update `STARCORE_API_KEY`,
  restart, update every client) — there is no dual-key grace-period
  mechanism. Not a concern at the current scale; worth an explicit ADR of
  its own if STARCORE ever needs zero-downtime key rotation.
- Regression coverage (`tests/test_auth.py`) already exercises every edge
  case this model implies: missing key, wrong key, empty key,
  different-length key, prefix-matching key (the specific shape a timing
  attack would probe), and unconfigured-server fail-closed behavior.
