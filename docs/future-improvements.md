# Future Improvements

> Status: Prioritized backlog after the offline platform build.

## Priority 1: deployment readiness

- Fix local Helm PATH and rerun chart validation locally.
- Configure AWS identity, account confirmation, and budget alerts.
- Deploy remote state, then the dev EKS platform.
- Capture screenshots for every checklist item.

## Priority 2: production hardening

- Add Karpenter or Cluster Autoscaler for node autoscaling.
- Add VPC endpoints to reduce public egress and NAT dependency.
- Add policy-as-code admission controls with Kyverno, Gatekeeper, or Validating
  Admission Policy.
- Add image scanning, SBOM generation, and image signing.
- Add branch protection and required environment approvals.

## Priority 3: advanced platform capabilities

- Add ExternalDNS and cert-manager for DNS/TLS automation.
- Add Argo Rollouts for canary or blue-green deployment.
- Evaluate EKS Pod Identity alongside IRSA.
- Add SLOs, error budgets, and alert review cadence.
- Split dev/stage/prod across AWS accounts and repositories.
