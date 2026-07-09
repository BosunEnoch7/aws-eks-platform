# Resilience Guide

> Status: Phase 11 baseline complete. These controls are desired state until
> the cluster is provisioned.

## What resilience means in this project

Resilience is the platform's ability to keep serving traffic during expected
change and partial failure.

For this phase, that means:

- scaling under load,
- safe rolling updates,
- protection during voluntary disruptions,
- spreading replicas across failure domains,
- making stuck rollouts visible.

## Implemented controls

### Metrics Server

Metrics Server is deployed as a platform component before workloads. The HPA
uses it to read current CPU and memory resource metrics.

Prometheus will still be added later for dashboards and alerting. Metrics Server
is not a long-term monitoring database.

### Horizontal Pod Autoscaler

The application uses `autoscaling/v2` with CPU utilization as the first scaling
signal.

Current baseline:

```text
minReplicas: 2
maxReplicas: 5
targetCPUUtilizationPercentage: 70
```

Scale-up is intentionally faster than scale-down. That favors availability
during traffic increases and avoids aggressive scale-down immediately after a
short spike.

### PodDisruptionBudget

The app uses a PDB with:

```text
maxUnavailable: 1
```

This helps during voluntary events such as node drains and node group updates.
It does not protect against sudden node failure.

### Topology spread

Pods prefer to spread across:

- `topology.kubernetes.io/zone`
- `kubernetes.io/hostname`

The policy uses `ScheduleAnyway` so a small dev cluster does not get stuck when
perfect spreading is impossible.

### Rolling updates

The Deployment uses:

```text
maxUnavailable: 0
maxSurge: 1
minReadySeconds: 10
progressDeadlineSeconds: 300
```

This makes rollouts conservative and easier to debug.

## Validation commands after deployment

```powershell
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl top nodes
kubectl top pods -n aws-eks-platform
kubectl get hpa -n aws-eks-platform
kubectl describe hpa aws-eks-platform-api -n aws-eks-platform
kubectl get pdb -n aws-eks-platform
kubectl rollout status deployment/aws-eks-platform-api -n aws-eks-platform
```

## Failure drills for later

- Increase load against `/work` and watch HPA scale replicas.
- Roll out a new image tag and confirm zero unavailable replicas.
- Drain one node and confirm the PDB limits disruption.
- Temporarily break readiness and confirm the rollout fails visibly.

These drills belong after the cluster exists and observability is installed.
