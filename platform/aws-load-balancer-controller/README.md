# AWS Load Balancer Controller

The controller watches Kubernetes Services and Ingress resources and reconciles
AWS load balancers. This platform initially uses it only to create the NLB
requested by ingress-nginx.

## Version

- Chart: `3.4.0`
- Controller: `3.4.0`
- IAM policy source: upstream controller release `v3.4.0`

## Before deployment

Replace these non-secret placeholders in an environment-specific values layer:

- `REPLACE_EKS_CLUSTER_NAME`
- `REPLACE_VPC_ID`
- `REPLACE_AWS_LOAD_BALANCER_CONTROLLER_ROLE_ARN`

Do not manually edit the common values during deployment. Phase 9 will add an
Argo CD environment overlay that supplies concrete values.

## Ownership

- Terraform creates the IRSA role and policy.
- This directory pins the Helm release and common values.
- Argo CD will own installation and reconciliation.
- The chart creates its Kubernetes service account with the Terraform role ARN
  annotation.

## Upgrade rule

Every upgrade must review:

1. Controller release notes
2. Chart values and Kubernetes compatibility
3. CRD changes
4. Upstream IAM policy changes
5. Enabled feature gates

Helm upgrades do not automatically update all controller CRDs in every release
path, so CRD ownership will be made explicit during GitOps bootstrap.

