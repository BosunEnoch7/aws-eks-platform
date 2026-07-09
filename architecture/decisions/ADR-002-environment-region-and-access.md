# ADR-002: Environment, Region, and Access Strategy

- Status: Accepted for initial implementation
- Date: 2026-07-04
- Decision owners: Olatubosun Enoch David and platform engineering

## Context

Before provisioning, the project needs a repeatable workstation model, an AWS
Region, and authentication boundaries for humans and automation. These choices
affect latency, service availability, cost, credential exposure, and whether
development actions can be safely reproduced.

## Decision

### Use `eu-west-1` as the initial AWS Region

Ireland is the initial Region because it has a mature AWS service footprint,
multiple Availability Zones, broad EKS ecosystem support, and a reasonable
network position for an operator in Lagos.

This is a default, not a hard-coded constant. Terraform will accept the Region
as an environment input so another Region can be evaluated deliberately.

Before Phase 5 provisioning, we will verify quotas, instance availability, and
current prices in the target account.

### Use separate local and automation identities

- A human operator will authenticate locally with an AWS named profile,
  preferably backed by IAM Identity Center or another temporary credential
  mechanism.
- GitHub Actions will authenticate through GitHub OIDC and assume a scoped IAM
  role.
- Static AWS access keys will not be stored in the repository or as the
  preferred CI authentication method.
- The AWS account root user will not perform routine provisioning.

### Use a named AWS profile

The project profile name will be `aws-eks-platform-dev`. Commands and Terraform
inputs will refer to it explicitly during local development. This prevents
silently using whichever credentials happen to be the workstation default.

The AWS account ID will be checked before every Terraform apply or destroy.

### Use Windows PowerShell as the supported local shell

The current workstation is Windows 11 with PowerShell. Documentation will use
PowerShell-compatible commands and path handling. CI will remain Linux-based so
the platform does not depend on Windows execution semantics.

### Pin important versions; do not freeze patch updates forever

The cluster will initially target Kubernetes `1.35`. It remains in EKS standard
support and is compatible with the currently installed `kubectl` `1.34`.

Terraform providers, Helm charts, and GitHub Actions will use explicit version
constraints or immutable commit references. Dependency updates will be reviewed
and tested rather than accepted silently.

## Why Kubernetes 1.35 instead of 1.36

Kubernetes `1.36` is the newest EKS standard-support version at the time of this
decision. The current `kubectl` client is `1.34`; AWS requires `kubectl` to be
within one minor version of the control plane. Selecting `1.35` is compatible
with the audited workstation and gives the newest release more time to mature.

This is not permission to ignore upgrades. The version must be rechecked
immediately before cluster creation.

## Consequences

### Benefits

- Local and CI credentials have separate trust paths.
- An explicit profile and identity check reduce wrong-account deployments.
- `kubectl` and control-plane versions begin in a supported skew.
- The Region remains configurable without pretending all Regions are identical.
- PowerShell instructions match the actual operator environment.

### Trade-offs

- `eu-west-1` may not be the cheapest or lowest-latency Region for every user.
- A named profile adds a small amount of command-line ceremony.
- Kubernetes `1.35` is not the absolute newest available version.
- Supporting PowerShell locally and Linux in CI requires scripts to avoid
  shell-specific assumptions.

## Revisit triggers

Revisit this ADR if:

- Measured latency, service availability, quota, compliance, or price favours a
  different Region.
- The target AWS organisation provides mandatory account or SSO conventions.
- Kubernetes `1.35` approaches the end of EKS standard support.
- A dev container or WSL becomes the preferred reproducible workstation.

## References

- [Amazon EKS Kubernetes version lifecycle](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)
- [Amazon EKS `kubectl` version-skew guidance](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
