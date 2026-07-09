# Metrics Server

Metrics Server provides the Kubernetes resource metrics API used by the
Horizontal Pod Autoscaler.

Why this matters:

- HPA can exist without Metrics Server, but CPU and memory scaling decisions
  will not work.
- Metrics Server is for near-real-time autoscaling signals, not long-term
  observability. Prometheus and Grafana will handle historical metrics later.
- The chart is deployed before workloads so the autoscaling feedback loop is
  available when the application arrives.
