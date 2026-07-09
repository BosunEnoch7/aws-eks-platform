# External Secrets Operator

External Secrets Operator syncs selected values from AWS Secrets Manager into
Kubernetes Secrets.

This platform uses the EKS service account credential pattern. The operator does
not receive static AWS access keys. Instead, each workload `SecretStore`
references an annotated Kubernetes service account that is allowed to assume a
least-privilege IAM role through IRSA.

Why this matters:

- AWS Secrets Manager remains the source of truth.
- Kubernetes receives only the runtime Secret it needs.
- Git contains references and policy, never secret values.
- Each workload can have its own IAM role and secret boundary.
