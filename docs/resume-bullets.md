# Resume Bullet Points

> Status: Draft bullets. Use "designed" or "implemented offline" until live AWS
> deployment evidence is captured.

## Platform / DevOps bullets

- Designed a production-inspired Amazon EKS platform using Terraform, modular
  AWS networking, managed node groups, ECR, IAM, and GitOps delivery patterns.
- Built a Helm-packaged FastAPI workload with probes, resource controls, HPA,
  PodDisruptionBudget, NetworkPolicy, ServiceMonitor, and PrometheusRule
  support.
- Implemented Argo CD App-of-Apps delivery for platform controllers, ingress,
  metrics, secrets, monitoring, dashboards, and application workloads.
- Designed least-privilege workload security using IRSA, AWS Secrets Manager,
  External Secrets Operator, restricted Pod Security Admission, and Kubernetes
  NetworkPolicy.
- Added GitHub Actions CI/CD for application tests, Terraform validation, Helm
  validation, Docker image build, ECR publishing, and GitOps image tag updates.
- Built an observability baseline with kube-prometheus-stack, Grafana dashboard
  discovery, Alertmanager routing placeholders, app metrics, and CloudWatch
  Observability add-on configuration.

## After live deployment, strengthen with evidence

- Replace "designed" with "deployed" only after Terraform apply and EKS
  validation screenshots exist.
- Add measured outcomes: rollout time, HPA scale behavior, alert firing time,
  recovery time, and cost profile.
