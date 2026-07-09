# ADR-006: Workload security and secrets model

## Status

Accepted

## Context

The platform needs to demonstrate production-inspired security without turning
the first EKS deployment into a large security product installation. The sample
application needs runtime configuration, future AWS access, and network
boundaries, but secret values must not be committed to Git.

## Decision

Use a layered baseline:

1. Terraform creates AWS Secrets Manager secret metadata.
2. Terraform creates one least-privilege IRSA role for the application service
   account.
3. External Secrets Operator syncs selected AWS Secrets Manager properties into
   a Kubernetes Secret.
4. The application Helm chart consumes the synced Kubernetes Secret only when
   `externalSecret.enabled=true`.
5. Argo CD labels the application namespace with restricted Pod Security
   Admission.
6. The application Helm chart creates a default NetworkPolicy.

## Why this decision

This design keeps clear ownership boundaries:

- Terraform owns AWS-side identity and secret metadata.
- Argo CD owns Kubernetes desired state.
- Helm owns the workload package.
- AWS Secrets Manager owns secret values.

It also avoids static AWS access keys. External Secrets Operator uses the EKS
service account credential pattern with IRSA.

## Trade-offs

- External Secrets Operator adds another controller to operate.
- Kubernetes Secrets still exist after sync, so RBAC and encryption still
  matter.
- Initial egress policy allows HTTPS to `0.0.0.0/0`; this is practical for a
  first dev platform but should be tightened with VPC endpoints later.
- Pod Security Admission is enforced on the app namespace first, not all
  platform namespaces.

## Consequences

The project now demonstrates:

- least-privilege AWS access for a Kubernetes workload,
- no secret values in Git,
- explicit network traffic boundaries,
- restricted workload posture,
- clear separation between infrastructure, platform, and application ownership.
