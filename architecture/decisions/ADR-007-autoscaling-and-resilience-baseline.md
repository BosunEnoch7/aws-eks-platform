# ADR-007: Autoscaling and resilience baseline

## Status

Accepted

## Context

The application should show more than a basic Deployment and HPA. A
production-inspired platform needs to survive normal events such as rolling
updates, node drains, short load spikes, and uneven scheduling.

## Decision

Use the following baseline:

1. Deploy Metrics Server before workloads through Argo CD.
2. Keep the application HPA on `autoscaling/v2`.
3. Tune HPA behavior:
   - scale up relatively quickly,
   - scale down more slowly to avoid replica flapping.
4. Keep at least two application replicas by default.
5. Use a `PodDisruptionBudget` with `maxUnavailable: 1`.
6. Use topology spread constraints across zones and hostnames.
7. Keep rolling updates conservative with `maxUnavailable: 0` and `maxSurge: 1`.
8. Use `minReadySeconds` and `progressDeadlineSeconds` to make rollout health
   explicit.

## Why this decision

HPA is reactive. It responds after metrics cross a threshold, so it needs
supporting controls that protect availability while the system catches up.

Metrics Server is required for CPU and memory based HPA signals. Prometheus is
still planned for observability, but Metrics Server is the lightweight metrics
pipeline used by Kubernetes autoscaling.

Topology spread reduces blast radius from a single node or zone issue.
PodDisruptionBudget protects the workload during voluntary disruption such as
node drain or managed node group updates.

## Trade-offs

- `minReplicas: 2` costs more than one replica, but avoids a fragile
  single-pod service.
- Fast scale-up can temporarily increase cost.
- Slow scale-down can keep extra replicas around after a spike.
- `ScheduleAnyway` topology spread improves distribution without blocking the
  scheduler when a small dev cluster has limited capacity.
- PDBs protect applications from voluntary disruption, but they do not prevent
  involuntary failures like node crashes.

## Consequences

The platform now demonstrates a realistic resilience posture:

- autoscaling has the metrics dependency it needs,
- rollouts are safer and observable,
- node drains have disruption protection,
- replicas prefer different nodes and zones,
- the application is better prepared for load and failure testing.
