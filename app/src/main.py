import os
import platform
import socket
import time
from typing import Any

from fastapi import FastAPI, HTTPException, Request, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest


STARTED_AT = time.time()

REQUEST_COUNT = Counter(
    "platform_api_http_requests_total",
    "Total HTTP requests served by the platform API.",
    ["method", "path", "status"],
)

REQUEST_LATENCY = Histogram(
    "platform_api_http_request_duration_seconds",
    "HTTP request latency for the platform API.",
    ["method", "path"],
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0),
)

WORK_DURATION = Histogram(
    "platform_api_work_duration_seconds",
    "Duration of synthetic CPU work requests.",
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5),
)


def read_bool(name: str, default: bool) -> bool:
    value = os.getenv(name)
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


def settings() -> dict[str, Any]:
    return {
        "app_name": os.getenv("APP_NAME", "aws-eks-platform-api"),
        "app_env": os.getenv("APP_ENV", "dev"),
        "app_version": os.getenv("APP_VERSION", "0.1.0"),
        "message": os.getenv("APP_MESSAGE", "Hello from Amazon EKS"),
        "readiness_enabled": read_bool("READINESS_ENABLED", True),
    }


app = FastAPI(
    title="AWS EKS Platform API",
    description="A small workload used to demonstrate Kubernetes platform operations.",
    version=os.getenv("APP_VERSION", "0.1.0"),
)


@app.middleware("http")
async def record_http_metrics(request: Request, call_next: Any) -> Response:
    route = request.url.path
    started = time.perf_counter()
    status_code = 500

    try:
        response = await call_next(request)
        status_code = response.status_code
        return response
    finally:
        duration = time.perf_counter() - started
        REQUEST_COUNT.labels(request.method, route, str(status_code)).inc()
        REQUEST_LATENCY.labels(request.method, route).observe(duration)


@app.get("/")
def root() -> dict[str, Any]:
    config = settings()
    return {
        "service": config["app_name"],
        "environment": config["app_env"],
        "message": config["message"],
        "hostname": socket.gethostname(),
    }


@app.get("/healthz")
def healthz() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/readyz")
def readyz() -> dict[str, str]:
    if not settings()["readiness_enabled"]:
        raise HTTPException(status_code=503, detail="readiness disabled")
    return {"status": "ready"}


@app.get("/version")
def version() -> dict[str, Any]:
    config = settings()
    return {
        "app_version": config["app_version"],
        "python": platform.python_version(),
        "uptime_seconds": round(time.time() - STARTED_AT, 3),
        "hostname": socket.gethostname(),
    }


@app.get("/metrics")
def metrics() -> Response:
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.get("/work")
def work(iterations: int = 250_000) -> dict[str, Any]:
    if iterations < 1 or iterations > 5_000_000:
        raise HTTPException(status_code=400, detail="iterations must be between 1 and 5000000")

    total = 0
    started = time.perf_counter()
    for number in range(iterations):
        total += number % 7

    duration_seconds = time.perf_counter() - started
    WORK_DURATION.observe(duration_seconds)
    duration_ms = round(duration_seconds * 1000, 3)
    return {
        "iterations": iterations,
        "duration_ms": duration_ms,
        "checksum": total,
    }
