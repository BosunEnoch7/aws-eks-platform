# ADR-008: Observability baseline

## Status

Accepted

## Context

The platform needs operational visibility into Kubernetes health, application
behavior, alerts, and AWS/EKS logs. The design should be realistic enough for
production discussion while remaining affordable for a development portfolio
environment.

## Decision

Use:

1. kube-prometheus-stack for Prometheus, Grafana, Alertmanager, and the
   Prometheus Operator.
2. App-owned `ServiceMonitor` and `PrometheusRule` resources in the application
   Helm chart.
3. Git-managed Grafana dashboards discovered by the Grafana sidecar.
4. EKS control-plane logs and the Amazon CloudWatch Observability add-on for
   AWS/EKS logging.
5. Placeholder Alertmanager receivers until a real notification destination is
   approved.

## Why this decision

Prometheus is the Kubernetes-native metrics and alerting standard. Grafana gives
human-readable dashboards. Alertmanager handles routing and deduplication.
CloudWatch remains the AWS-native log destination for EKS and container logs.

Putting application monitors and rules in the app chart keeps service ownership
clear: the workload team owns the signals that define whether the workload is
healthy.

## Trade-offs

- kube-prometheus-stack is powerful but large.
- Prometheus persistence is disabled initially to reduce cost.
- Placeholder alert receivers prevent accidental noisy notifications.
- CloudWatch and Prometheus overlap in some areas, so the project explicitly
  separates logs from metrics.

## Consequences

The platform now has an observability operating model:

- metrics are scraped automatically,
- dashboards are managed from Git,
- service alerts live with the service,
- AWS/EKS logs flow toward CloudWatch,
- future incident drills can be tied to real signals.
