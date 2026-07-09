# Development Environment

This root module composes the development platform. Phase 6 adds ECR, IAM, the
EKS control plane, a managed system node group, and EKS-managed core add-ons.

## Current network profile

- Region: `eu-west-1`
- VPC: `10.0.0.0/16`
- Three public `/24` subnets
- Three private `/24` subnets
- One shared NAT gateway for development cost control
- EKS nodes will use private subnets
- EKS 1.35 with API-based access entries
- One desired On-Demand `t3.medium` node for short live-demo windows
- VPC CNI permissions isolated through IRSA
- Immutable, scan-on-push ECR application repository

## Required account-specific inputs

The example values for `cluster_public_access_cidrs` and
`cluster_admin_principal_arn` are deliberately invalid for real deployment.
Replace them with:

- The operator's current public IP as a `/32`, or an approved corporate CIDR
- A federated IAM role ARN that must receive initial cluster administration

The module prohibits `0.0.0.0/0`.

## Backend

The backend block uses partial S3 configuration. Copy
`backend.hcl.example` to the ignored `backend.hcl`, replace the account ID, and
initialise only after the bootstrap state bucket exists:

```powershell
terraform init -backend-config=backend.hcl
```

Do not put credentials in `backend.hcl`.

## Cost warning

Applying this environment creates a NAT gateway and an Elastic IP even before
EKS exists. The NAT gateway has hourly and data-processing charges.

The single-NAT development setting reduces cost but creates a single-AZ egress
dependency. The one-node live lab setting reduces cost further, but it is not a
high-availability production posture. Production should normally use multiple
nodes across Availability Zones and one NAT gateway per Availability Zone or a
deliberately designed alternative.
