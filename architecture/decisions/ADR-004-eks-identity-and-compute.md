# ADR-004: EKS Identity, Add-ons, and Compute Model

- Status: Accepted for offline implementation
- Date: 2026-07-04
- Decision owners: Olatubosun Enoch David and platform engineering

## Context

The EKS layer must establish human access, workload identity, cluster add-ons,
compute capacity, image storage, and logging without relying on legacy
authentication or granting application permissions to every worker node.

## Decision

### Use Kubernetes 1.35 in EKS standard-support mode

Version 1.35 is within the supported version skew of the audited `kubectl`
1.34 client and remains in EKS standard support. The version is explicit and
must be revalidated before an AWS plan or apply.

### Use EKS access entries in `API` authentication mode

The cluster will not depend on the legacy `aws-auth` ConfigMap for human
administration. Bootstrap cluster-creator administration is disabled.

An explicitly supplied federated IAM role receives an EKS access entry and the
cluster-admin access policy. This makes access recoverable and auditable through
the EKS API.

### Restrict the public API endpoint

The EKS API has private access enabled and public access limited to explicit
operator `/32` CIDRs. A caller must provide those CIDRs; the module does not
default to `0.0.0.0/0`.

This keeps local administration practical without presenting the API endpoint
to the entire internet. A fully private endpoint remains the stronger
production option when VPN, Direct Connect, or a controlled operator network is
available.

### Use managed node groups with bounded capacity

The development node group uses:

- Amazon Linux 2023 EKS-optimised images
- On-Demand instances
- Desired capacity of two nodes
- Minimum one and maximum three nodes
- Private subnets only

On-Demand capacity keeps interruption behaviour out of the first platform
bootstrap. Spot capacity will later be added as a separate, disruption-tolerant
pool rather than silently weakening the system node group.

### Separate VPC CNI permissions from the node role

The node role receives only the EKS worker-node and ECR pull policies required
for basic node operation. The VPC CNI receives `AmazonEKS_CNI_Policy` through a
dedicated IRSA role bound to `kube-system/aws-node`.

This demonstrates the central IRSA principle: Pod permissions belong to a
service account, not every process running on a node.

### Use EKS-managed core add-ons

EKS will manage:

- Amazon VPC CNI
- CoreDNS
- `kube-proxy`

Versions are intentionally selected by EKS compatibility during initial
creation. Before production upgrades, compatible add-on versions will be
planned and pinned explicitly.

### Use default EKS envelope encryption

EKS 1.35 encrypts all Kubernetes API data with default envelope encryption
using an AWS-owned key. A customer-managed KMS key is not added initially
because it introduces cost, key-policy lifecycle, and a cluster availability
dependency without a stated compliance requirement.

### Use immutable ECR releases

The application repository uses immutable tags, scan-on-push, encryption, and a
lifecycle policy that removes stale untagged images while retaining a bounded
release history.

## Consequences

### Benefits

- Human access is explicit and does not depend on `aws-auth`.
- Cluster creator credentials do not receive hidden permanent administration.
- The API endpoint has a defined network boundary.
- VPC CNI permissions are isolated through IRSA.
- Nodes are replaceable and capacity is bounded.
- Images are traceable and cannot be overwritten under an existing tag.

### Costs and risks

- Two On-Demand nodes create a meaningful recurring development cost.
- A public API endpoint, even CIDR-restricted, has more exposure than a private
  endpoint.
- The initial cluster-admin access policy is broad and must be narrowed as
  personas are introduced.
- Managed add-on upgrades still require compatibility testing.
- IRSA requires an OIDC provider and careful trust-policy conditions.
- Immutable tags require CI to generate a new release identifier every time.

## References

- [EKS access entries](https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html)
- [EKS node IAM role](https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html)
- [VPC CNI with IRSA](https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html)
- [Default EKS envelope encryption](https://docs.aws.amazon.com/eks/latest/userguide/envelope-encryption.html)

