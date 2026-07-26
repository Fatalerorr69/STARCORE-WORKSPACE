"""
Request Correlation ID Tests
"""

from __future__ import annotations

import re

from core.main import _REQUEST_ID_PATTERN, _resolve_request_id, app
from fastapi.testclient import TestClient
from loguru import logger

client = TestClient(app)
client.headers.update({"X-API-Key": "test-api-key"})

_UUID4 = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$")


# ---------------------------------------------------------------------------
# _resolve_request_id unit tests
# ---------------------------------------------------------------------------


def test_resolve_request_id_generates_when_missing():
    result = _resolve_request_id(None)
    assert _UUID4.match(result)


def test_resolve_request_id_generates_when_empty():
    result = _resolve_request_id("")
    assert _UUID4.match(result)


def test_resolve_request_id_accepts_valid_supplied_id():
    assert _resolve_request_id("my-trace-id-123") == "my-trace-id-123"


def test_resolve_request_id_rejects_id_with_whitespace():
    result = _resolve_request_id("bad id with spaces")
    assert _UUID4.match(result)


def test_resolve_request_id_rejects_id_with_newline():
    result = _resolve_request_id("bad-id\nwith-newline")
    assert _UUID4.match(result)


def test_resolve_request_id_rejects_id_over_128_chars():
    result = _resolve_request_id("a" * 129)
    assert _UUID4.match(result)


def test_resolve_request_id_accepts_id_at_128_char_boundary():
    candidate = "a" * 128
    assert _resolve_request_id(candidate) == candidate


def test_request_id_pattern_allows_alnum_hyphen_underscore():
    assert _REQUEST_ID_PATTERN.fullmatch("abc-DEF_123")


# ---------------------------------------------------------------------------
# Middleware / response header
# ---------------------------------------------------------------------------


def test_response_includes_generated_request_id_header():
    response = client.get("/health")
    assert _UUID4.match(response.headers["x-request-id"])


def test_response_echoes_supplied_valid_request_id():
    response = client.get("/health", headers={"X-Request-ID": "caller-supplied-trace"})
    assert response.headers["x-request-id"] == "caller-supplied-trace"


def test_response_replaces_invalid_supplied_request_id():
    response = client.get("/health", headers={"X-Request-ID": "not a valid id!"})
    assert response.headers["x-request-id"] != "not a valid id!"
    assert _UUID4.match(response.headers["x-request-id"])


def test_sequential_requests_without_supplied_id_get_different_ids():
    r1 = client.get("/health")
    r2 = client.get("/health")
    assert r1.headers["x-request-id"] != r2.headers["x-request-id"]


# ---------------------------------------------------------------------------
# Logging context propagation
# ---------------------------------------------------------------------------


def test_request_id_is_bound_to_log_records_during_the_request():
    captured = []
    sink_id = logger.add(lambda message: captured.append(message.record), level="WARNING")
    try:
        payload = {
            "name": "req-id-log-test",
            "version": "1.0",
            "resources": [{"name": "thing", "provider": "ghost", "kind": "svc", "config": {}}],
        }
        response = client.post(
            "/blueprints/run", json=payload, headers={"X-Request-ID": "log-trace-42"}
        )
        assert response.status_code == 200
    finally:
        logger.remove(sink_id)

    matching = [r for r in captured if r["extra"].get("request_id") == "log-trace-42"]
    assert matching, "expected at least one log record bound to this request's ID"


def test_request_id_reverts_to_default_outside_request_context():
    captured = []
    sink_id = logger.add(lambda message: captured.append(message.record), level="INFO")
    try:
        logger.info("outside any request")
    finally:
        logger.remove(sink_id)

    assert captured[-1]["extra"]["request_id"] == "-"
