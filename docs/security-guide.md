# Security Guide

> Status: Phase 10 baseline complete. Controls are implemented as offline
> desired state and become enforceable only after the cluster is provisioned.

## Security objectives

- Use short-lived human and CI credentials.
- Apply least privilege to users, nodes, controllers, and workloads.
- Keep secret values outside Git and CI logs.
- Restrict network paths to required communication.
- Build, scan, and trace immutable artifacts.
- Make privileged changes reviewable and auditable.

## Implemented baseline

### 1. Workload identity

The sample application uses IAM Roles for Service Accounts (IRSA), not node
instance role permissions. Terraform creates an IAM role trusted only by:

```text
system:serviceaccount:aws-eks-platform:aws-eks-platform-api
```

Why: if the app needs AWS permissions, those permissions should belong to the
app identity, not every workload running on the node.

Trade-off: IRSA is still not a container isolation boundary. It reduces AWS API
blast radius, but pods on the same node still share the node kernel.

### 2. Secret management

AWS Secrets Manager is the source of truth for runtime secret values.
Terraform creates the secret metadata and IAM policy boundary, but does not
commit or generate the secret value.

External Secrets Operator syncs selected secret properties into a Kubernetes
Secret. The application consumes the resulting Kubernetes Secret through
environment variables.

Why: Git should hold desired state and references, not passwords or tokens.

Trade-off: once synced, the value exists as a Kubernetes Secret, so Kubernetes
RBAC, audit logging, and cluster encryption still matter.

### 3. Pod Security Admission

The `aws-eks-platform` namespace is labeled with restricted Pod Security
Admission settings through Argo CD namespace metadata:

```text
pod-security.kubernetes.io/enforce=restricted
pod-security.kubernetes.io/audit=restricted
pod-security.kubernetes.io/warn=restricted
```

Why: this prevents common unsafe workload patterns, such as privileged pods,
host namespace access, and permissive Linux capabilities.

Trade-off: platform controller namespaces are not set to `restricted` yet
because ingress and infrastructure controllers may need permissions that app
workloads should not have.

### 4. Container hardening

The application chart runs the container as non-root, disables privilege
escalation, drops Linux capabilities, sets resource requests and limits, and
uses a read-only root filesystem.

Why: if an attacker gets code execution inside the container, these controls
reduce easy privilege escalation paths.

Trade-off: read-only filesystems require apps to write only to approved
locations. This sample app does not need a writable application directory.

### 5. Network policies

The app chart creates a namespace-scoped `NetworkPolicy`:

- ingress is allowed only from the `ingress-nginx` namespace to the app port,
- DNS egress is allowed to `kube-system`,
- HTTPS egress is allowed for external service access.

Why: Kubernetes networking is open by default. Network policies make allowed
communication explicit.

Trade-off: HTTPS egress is intentionally broad for now. A stricter production
design would add VPC endpoints for AWS APIs and reduce public internet egress.

## What is not complete yet

- CI secret scanning and image scanning.
- Kubernetes RBAC personas beyond Argo CD and controller defaults.
- VPC endpoints for private AWS API access.
- KMS customer-managed keys for Secrets Manager and EKS envelope encryption.
- Runtime threat detection.
- Admission policy as code with Kyverno, Gatekeeper, or Validating Admission
  Policy.

These are future hardening layers, not omissions from the Phase 10 baseline.
