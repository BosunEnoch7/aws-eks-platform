# kube-prometheus-stack

This stack installs Prometheus, Grafana, Alertmanager, Prometheus Operator, and
the common Kubernetes monitoring rules.

Design choices:

- Prometheus keeps seven days of metrics for the development platform.
- Persistent storage is disabled for the first dev phase to avoid accidental
  EBS cost and lifecycle complexity.
- Grafana dashboard sidecar is enabled so dashboards can be managed from Git.
- Alertmanager has placeholder receivers until a real notification channel is
  approved.
- EKS control-plane components such as etcd, scheduler, and controller-manager
  are not scraped directly because AWS manages those components.

This is observability desired state only. It should be deployed after the EKS
cluster exists and the safety gate has been cleared.
