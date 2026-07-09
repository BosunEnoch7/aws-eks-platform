# AWS EKS Platform

`aws-eks-platform` is a production-inspired Kubernetes platform on Amazon EKS.
It demonstrates how a platform team provisions infrastructure, packages
workloads, delivers immutable releases through GitOps, secures workload access
to AWS, and operates the resulting system.

> Status: Offline platform build complete through Phase 14. AWS planning and
> provisioning remain blocked on identity verification and budget guardrails.

## Owner

Olatubosun Enoch David

## Platform objectives

- Provision AWS infrastructure reproducibly with Terraform.
- Run containerized workloads on Amazon EKS managed node groups.
- Store immutable application images in Amazon ECR.
- Package Kubernetes workloads with Helm.
- Separate continuous integration from Argo CD-based continuous delivery.
- Expose applications through an AWS NLB and NGINX Ingress.
- Use IRSA and AWS Secrets Manager for least-privilege secret access.
- Implement Kubernetes security, autoscaling, observability, and operational
  documentation.

## Architecture

The initial design and its responsibility boundaries are documented in:

- [Architecture overview](architecture/diagrams/platform-architecture.md)
- [ADR-001: EKS platform operating model](architecture/decisions/ADR-001-eks-platform-operating-model.md)
- [ADR-005: Ingress and controller ownership](architecture/decisions/ADR-005-ingress-and-controller-ownership.md)
- [ADR-006: Workload security and secrets model](architecture/decisions/ADR-006-workload-security-and-secrets-model.md)
- [ADR-007: Autoscaling and resilience baseline](architecture/decisions/ADR-007-autoscaling-and-resilience-baseline.md)
- [ADR-008: Observability baseline](architecture/decisions/ADR-008-observability-baseline.md)
- [ADR-009: CI/CD and release automation](architecture/decisions/ADR-009-ci-cd-and-release-automation.md)

## Repository structure

```text
.
|-- .github/workflows/       CI, validation, and release workflows
|-- app/                     Sample application source, tests, and image definition
|-- architecture/
|   |-- decisions/           Architecture Decision Records
|   `-- diagrams/            Platform and request-flow diagrams
|-- docs/                    Deployment, operations, security, and career documentation
|-- gitops/
|   |-- applications/        Argo CD application definitions
|   |-- bootstrap/           Minimum resources needed to establish GitOps
|   `-- environments/        Desired state for each environment
|-- helm/application/        Reusable application Helm chart
|-- platform/                Cluster-wide controllers and operational add-ons
|-- policies/                Network and workload security policies
|-- screenshots/             Curated implementation evidence
|-- scripts/                 Small repeatable operator commands
|-- terraform/
|   |-- bootstrap/           Terraform state and initial trust resources
|   |-- environments/        Environment composition
|   `-- modules/             Reusable infrastructure modules
`-- tests/                   Infrastructure, Kubernetes, and smoke tests
```

Directories intentionally contain placeholder files until their implementation
phase. This keeps the planned ownership boundaries visible without prematurely
adding code.

## Delivery model

```text
Developer -> GitHub -> GitHub Actions -> ECR
                                      -> Git desired state
                                             |
                                             v
                                          Argo CD
                                             |
                                             v
                                             EKS
```

GitHub Actions will build and validate artifacts. Argo CD will be the normal
authority that deploys workloads. CI will not directly apply production
manifests to the cluster.

## Planned phases

1. Platform concepts and architecture
2. Repository and architecture foundation
3. AWS and local-tool prerequisites
4. Terraform remote state and provider foundation - apply deferred
5. VPC and networking
6. ECR, IAM, and EKS **(offline implementation complete)**
7. Platform controllers and ingress **(offline implementation complete)**
8. Sample application and Helm chart **(offline implementation complete)**
9. GitOps with Argo CD **(offline implementation complete)**
10. Security, secrets, and network policies **(offline implementation complete)**
11. Autoscaling and resilience **(offline implementation complete)**
12. Monitoring, alerting, and logging **(offline implementation complete)**
13. CI, validation, and release automation **(offline implementation complete)**
14. Operational testing and final documentation **(offline implementation complete)**

## Offline validation

Run the local validation helper from the repository root:

```powershell
.\scripts\local_validate.ps1
```

If Terraform has not been initialized yet, run:

```powershell
terraform -chdir=terraform/environments/dev init -backend=false
```

This validation does not create AWS resources.

Each phase is reviewed and approved before the next phase begins.

## Current safety gate

No AWS resources have been created yet. Before running `terraform plan` or
`terraform apply`, this project needs:

1. an authenticated AWS CLI profile,
2. confirmation of the AWS account/identity being used,
3. a budget alert email address,
4. confirmation or replacement of the current `$50/month` budget target.

This keeps the platform production-inspired without turning the learning
environment into a surprise bill generator. Very unglamorous. Very necessary.

## Documentation

See the [documentation index](docs/README.md) for the planned guides,
runbooks, interview material, and evidence checklist.
