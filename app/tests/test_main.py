from fastapi.testclient import TestClient

from src.main import app


client = TestClient(app)


def test_healthz_returns_ok() -> None:
    response = client.get("/healthz")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_readyz_returns_ready() -> None:
    response = client.get("/readyz")

    assert response.status_code == 200
    assert response.json() == {"status": "ready"}


def test_version_exposes_release_metadata() -> None:
    response = client.get("/version")

    assert response.status_code == 200
    payload = response.json()
    assert "app_version" in payload
    assert "python" in payload
    assert "uptime_seconds" in payload


def test_work_endpoint_rejects_unbounded_input() -> None:
    response = client.get("/work", params={"iterations": 5_000_001})

    assert response.status_code == 400


def test_metrics_endpoint_exposes_prometheus_metrics() -> None:
    response = client.get("/metrics")

    assert response.status_code == 200
    assert "platform_api_http_requests_total" in response.text
