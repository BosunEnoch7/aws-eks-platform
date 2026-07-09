# Production Best Practices

> Status: Baseline complete. Items are marked as implemented, partially
> implemented, or future work.

| Area | Current state | Production recommendation |
|---|---|---|
| AWS accounts | Single dev environment | Separate dev/stage/prod accounts |
| Networking | Multi-AZ VPC, private nodes | Add VPC endpoints and stricter egress |
| EKS access | API access entries | Add RBAC personas and break-glass process |
| Workload identity | IRSA | Evaluate EKS Pod Identity for future workloads |
| Secrets | Secrets Manager + ESO design | Add KMS CMK, rotation, and access review |
| Pod security | Restricted app namespace | Add admission policy-as-code |
| Network policy | App default-deny pattern | Add tested egress allowlists |
| Autoscaling | HPA + metrics-server | Add Cluster Autoscaler or Karpenter |
| Rollouts | RollingUpdate | Consider Argo Rollouts for canary/blue-green |
| Observability | Prometheus/Grafana/Alertmanager/CloudWatch | Add SLOs and alert review cadence |
| CI/CD | GitHub Actions + GitOps | Add branch protection and required approvals |
| Supply chain | Docker build validation | Add image scanning, signing, SBOMs |
| Recovery | Runbooks | Add backup/restore drills |

## Non-negotiables before production

- restrict who can approve Terraform applies,
- require CI before merge,
- test rollback before the first release,
- define alert ownership,
- define teardown and disaster recovery steps,
- document accepted risk for any cost-saving compromise.
