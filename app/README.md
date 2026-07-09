# Sample Platform Application

This service is intentionally small, but it is designed like a workload that a
platform team can operate:

- `/healthz` supports Kubernetes liveness probes.
- `/readyz` supports Kubernetes readiness probes.
- `/version` exposes release metadata for rollout verification.
- `/work` generates bounded CPU work for HPA demonstrations.
- Configuration comes from environment variables so Kubernetes `ConfigMap`
  integration is visible.

The goal is not to build a complex business application. The goal is to create
an application that proves the EKS platform can build, release, route, observe,
scale, and troubleshoot workloads.

## Local run

```powershell
cd app
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements-dev.txt
uvicorn src.main:app --host 0.0.0.0 --port 8080
```

Then test:

```powershell
Invoke-RestMethod http://localhost:8080/healthz
Invoke-RestMethod http://localhost:8080/readyz
Invoke-RestMethod http://localhost:8080/version
```

## Container build

```powershell
docker build -t aws-eks-platform-app:local app
docker run --rm -p 8080:8080 aws-eks-platform-app:local
```

Docker Desktop must be running for the container commands.
