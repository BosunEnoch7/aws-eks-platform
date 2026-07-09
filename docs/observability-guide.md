# Observability Guide

> Status: Phase 12 baseline complete. Resources are defined as desired state
> and have not been deployed yet.

## Observability model

This project separates observability into four signals:

- metrics: Prometheus and kube-prometheus-stack,
- dashboards: Grafana,
- alerts: PrometheusRule and Alertmanager,
- logs: EKS control-plane logs and the Amazon CloudWatch Observability add-on.

## Metrics

The sample FastAPI app exposes `/metrics` using `prometheus-client`.

Custom metrics include:

- `platform_api_http_requests_total`
- `platform_api_http_request_duration_seconds`
- `platform_api_work_duration_seconds`

The Helm chart creates a `ServiceMonitor` so Prometheus discovers the app
automatically.

## Dashboards

Grafana is installed through kube-prometheus-stack. Dashboard sidecar discovery
is enabled with this label:

```text
grafana_dashboard=1
```

The starter dashboard tracks:

- request rate,
- 5xx error ratio,
- p95 latency.

## Alerts

The app chart owns service-level alerts:

- `PlatformApiHighErrorRate`
- `PlatformApiHighLatency`
- `PlatformApiNoTrafficMetrics`

Alertmanager currently uses placeholder receivers. Real email, Slack, PagerDuty,
or SNS routing should be added only after the notification target is approved.

## Logs

EKS control-plane logs are already enabled in Terraform for:

- API server,
- audit,
- authenticator,
- controller manager,
- scheduler.

The EKS module also defines the Amazon CloudWatch Observability add-on for
container log collection.

## Validation commands after deployment

```powershell
kubectl get pods -n monitoring
kubectl get servicemonitor -n aws-eks-platform
kubectl get prometheusrule -n aws-eks-platform
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
kubectl logs -n amazon-cloudwatch -l app.kubernetes.io/name=amazon-cloudwatch-observability-agent
```

## Trade-offs

- Prometheus persistence is disabled in the first dev profile to reduce storage
  cost and lifecycle complexity.
- Alertmanager receivers are placeholders to avoid accidentally sending noisy
  alerts.
- CloudWatch is used for AWS/EKS log integration; Prometheus is used for
  metrics and alerting.
