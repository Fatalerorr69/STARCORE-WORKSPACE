from __future__ import annotations

import hmac

from fastapi import Header, HTTPException

from core.config import get_settings


def verify_api_key(x_api_key: str | None = Header(default=None, alias="X-API-Key")) -> None:
    settings = get_settings()
    if not settings.api_key:
        raise HTTPException(
            status_code=503,
            detail="API key not configured on server. Set STARCORE_API_KEY in .env.",
        )
    # Constant-time comparison: a plain `!=` here would leak the number of
    # matching leading characters via response-timing differences to a
    # network-positioned attacker. compare_digest() is safe for this even
    # though `x_api_key` is attacker-controlled, because it always compares
    # the full length of both inputs regardless of where they first differ.
    if x_api_key is None or not hmac.compare_digest(x_api_key, settings.api_key):
        raise HTTPException(
            status_code=401,
            detail="Missing or invalid API key. Provide it via the X-API-Key header.",
        )
