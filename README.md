# AWS EKS Platform

`aws-eks-platform` is a production-inspired Kubernetes platform on Amazon EKS.
It demonstrates how a platform engineering team can provision cloud
infrastructure, package applications, deliver releases through GitOps, secure
workload access to AWS, and operate Kubernetes with observability and cost
guardrails.

> Publishing gate: this repository is not ready to push until screenshot
> evidence is collected in `docs/images/` and displayed in this README.

## Project Overview

This project models a realistic AWS Kubernetes platform rather than a basic EKS
tutorial. The goal is to show end-to-end platform thinking:

- Terraform-managed AWS infrastructure
- Amazon EKS for managed Kubernetes
- Amazon ECR for container images
- Helm for reusable workload packaging
- Argo CD for GitOps delivery
- NGINX Ingress and AWS Load Balancer integration
- HPA, probes, network policies, and pod security controls
- Prometheus, Grafana, Alertmanager, and CloudWatch observability
- GitHub Actions for CI validation and release automation
- Security and cost-conscious operating practices

## Architecture Diagram

The platform flow is:

```text
Developer
   |
   v
GitHub
   |
   v
GitHub Actions
   |
   +--> Docker Build/Test
   |
   +--> Amazon ECR
   |
   v
GitOps Desired State
   |
   v
Argo CD
   |
   v
Amazon EKS
   |
   v
NGINX Ingress / AWS Load Balancer
   |
   v
Kubernetes Service
   |
   v
Application Pods
   |
   +--> Prometheus --> Grafana
   |
   +--> Alertmanager
   |
   +--> CloudWatch Logs
```

Detailed architecture notes are maintained in
[architecture/diagrams/platform-architecture.md](architecture/diagrams/platform-architecture.md)
and the ADRs under [architecture/decisions](architecture/decisions).

## Screenshot Evidence

Screenshot evidence is mandatory before this repository is pushed to GitHub.
Evidence must be stored in `docs/images/` and displayed here.

Required evidence includes:

- Terraform apply success
- EKS cluster and node group
- ECR image repository
- Kubernetes resources from `kubectl`
- Application running
- GitHub Actions success
- Helm release output
- Argo CD dashboard
- Prometheus targets
- Grafana dashboard
- Alertmanager
- CloudWatch logs

Current status: screenshots are not yet collected, so the repository must not
be pushed.

## Technologies Used and Why

| Technology | Why it is used |
|---|---|
| AWS | Provides the cloud foundation for networking, compute, identity, logging, and container registry services. |
| Amazon EKS | Runs Kubernetes while AWS manages the control plane lifecycle. |
| Amazon ECR | Stores immutable Docker images close to EKS and integrates with IAM. |
| Terraform | Provisions infrastructure reproducibly and makes architecture reviewable. |
| Docker | Packages the sample API into a portable container image. |
| Kubernetes | Provides workload orchestration, service discovery, rollout control, and autoscaling. |
| Helm | Templates Kubernetes resources into a reusable application package. |
| Argo CD | Keeps cluster state synchronized from Git and separates CI from deployment authority. |
| GitHub Actions | Runs validation, tests, image build, and release automation. |
| NGINX Ingress | Provides HTTP routing inside Kubernetes. |
| AWS Load Balancer Controller | Integrates Kubernetes ingress/service resources with AWS load balancers. |
| IRSA | Grants AWS permissions to Kubernetes service accounts without static credentials. |
| AWS Secrets Manager | Keeps runtime secrets outside Git. |
| Prometheus/Grafana/Alertmanager | Provides metrics collection, dashboards, and alert routing. |
| CloudWatch | Captures AWS and EKS operational logs. |

## Project Structure

```text
.
|-- .github/workflows/       CI, validation, and release workflows
|-- app/                     Sample FastAPI application, tests, and Dockerfile
|-- architecture/
|   |-- decisions/           Architecture Decision Records
|   `-- diagrams/            Platform architecture notes
|-- docs/                    Public deployment, operations, security, and evidence docs
|-- docs/images/             Screenshot evidence required before publishing
|-- gitops/                  Argo CD projects, bootstrap, and applications
|-- helm/application/        Application Helm chart
|-- k8s/                     Lightweight live-validation manifest
|-- monitoring/              Monitoring documentation and references
|-- platform/                Cluster add-ons and controller values
|-- scripts/                 Local validation and operator helper scripts
|-- terraform/
|   |-- bootstrap/           Remote state and budget/bootstrap foundation
|   |-- environments/        Environment composition
|   `-- modules/             Reusable AWS infrastructure modules
`-- tests/                   Test and validation assets
```

## Infrastructure Design

The Terraform design is split into reusable modules:

- `vpc`: public/private subnets, routing, internet gateway, and NAT pattern
- `ecr`: container registry and lifecycle policy
- `eks`: EKS control plane, managed node group, add-ons, IAM roles, OIDC, and access entries
- `platform-iam`: controller IAM roles and policies
- `workload-security`: application runtime secret metadata and IRSA permissions

The dev environment is intentionally cost-conscious:

- one managed node group
- `t3.small` nodes for learning/demo use
- single NAT Gateway instead of one NAT per Availability Zone
- restricted EKS public endpoint CIDR
- explicit budget guardrails

## Features

- Modular Terraform infrastructure
- Remote-state bootstrap design
- EKS managed node group
- ECR repository and lifecycle policy
- FastAPI sample service with health, readiness, version, and metrics endpoints
- Docker image build workflow
- Helm chart with Deployment, Service, Ingress, HPA, PDB, NetworkPolicy, ConfigMap, ServiceMonitor, and PrometheusRule
- Argo CD GitOps application definitions
- IRSA-based workload access to AWS services
- CloudWatch observability add-on
- Prometheus/Grafana/Alertmanager platform design
- Public-safe documentation and runbooks
- Cost-safety handoff after live validation attempts

## Deployment Guide

Read the full guide at [docs/deployment-guide.md](docs/deployment-guide.md).

High-level workflow:

```powershell
cd terraform/bootstrap
terraform init
terraform plan
terraform apply

cd ../environments/dev
terraform init -reconfigure -backend-config=backend.hcl
terraform plan
terraform apply
```

After EKS is active:

```powershell
aws eks update-kubeconfig `
  --name aws-eks-platform-dev `
  --region eu-west-1 `
  --profile aws-eks-platform-dev `
  --role-arn arn:aws:iam::637739133052:role/aws-eks-platform-eks-cluster-admin

kubectl get nodes
kubectl get pods -A
```

## Local Development Guide

The sample application lives in [app](app).

```powershell
cd app
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt -r requirements-dev.txt
pytest
```

Build the image:

```powershell
docker build -t aws-eks-platform-api:local ./app
```

## CI/CD Pipeline

GitHub Actions is responsible for:

- linting and testing the application
- validating Terraform formatting
- validating YAML/Kubernetes manifests
- building the Docker image
- pushing release images to ECR
- updating GitOps image references

Argo CD is responsible for deployment. This separation matters because CI
should produce verified artifacts, while GitOps should own cluster state.

## Monitoring and Observability

The monitoring design includes:

- Prometheus for metrics collection
- Grafana for dashboards
- Alertmanager for alert routing
- ServiceMonitor and PrometheusRule templates in the Helm chart
- CloudWatch for EKS control-plane and container log visibility

See [docs/observability-guide.md](docs/observability-guide.md).

## Security

Security controls include:

- no committed credentials, `.env` files, Terraform state, or kubeconfigs
- restricted EKS API endpoint CIDR
- IAM Roles for Service Accounts instead of static AWS keys
- AWS Secrets Manager as the external secret source
- non-root containers
- read-only root filesystem where practical
- dropped Linux capabilities
- liveness and readiness probes
- Kubernetes NetworkPolicy templates
- public documentation only in Git

See [docs/security-guide.md](docs/security-guide.md).

## Cost Optimization

The project is designed for short-lived validation rather than always-on lab
usage. Main cost drivers are:

- EKS control plane
- NAT Gateway
- EC2 worker node
- load balancers
- CloudWatch log ingestion/storage

Cost controls:

- use a single NAT Gateway for dev
- keep node count low
- tear down live infrastructure after evidence capture
- use AWS Budgets
- avoid leaving load balancers running

See [docs/cost-optimization-guide.md](docs/cost-optimization-guide.md).

## Troubleshooting Guide

The project includes troubleshooting documentation for:

- AWS identity/profile issues
- Terraform backend/state drift
- EKS endpoint CIDR lockout
- `kubectl` context mistakes
- pod scheduling and rollout failures
- CloudWatch/observability injection conflicts
- cost-safety cleanup

See [docs/troubleshooting-guide.md](docs/troubleshooting-guide.md) and
[docs/live-validation-handoff.md](docs/live-validation-handoff.md).

## Live Validation Status

Live AWS validation was attempted in `eu-west-1`.

Validated:

- AWS identity/profile
- Terraform bootstrap foundation
- ECR image push
- EKS infrastructure creation path
- cost-safety cleanup checks

Blocked:

- final Kubernetes application proof and screenshots

Root cause:

- CloudTrail showed `aws-eks-platform-dev` was deleted by an AWS CLI
  `eks.delete-cluster` command from the `bosun-admin` user during validation.

Current cost-safety status:

- no project EKS cluster
- no project NAT Gateway
- no project Elastic IP
- no project EC2 instance
- no project load balancer

## Lessons Learned

- EKS endpoint CIDR restrictions are secure, but operator IP changes can break access.
- Terraform state drift must be handled carefully after manual cloud deletion.
- Cost control is part of platform engineering, not an afterthought.
- GitOps should own deployments; CI should build and validate artifacts.
- Observability add-ons can mutate workloads and interact with Pod Security Admission.
- Recruiter-ready repositories need evidence, not just code.

## Future Improvements

- Add real screenshot evidence under `docs/images/`
- Complete final live Kubernetes rollout after stopping external delete commands
- Add automated smoke tests after Argo CD sync
- Add OPA/Kyverno policy checks
- Add external DNS and TLS automation
- Add environment promotion workflow
- Add disaster recovery and backup validation

## Repository Safety Notice

Private career materials are intentionally excluded from Git:

- interview guides
- STAR stories
- LinkedIn posts/guides
- resume/CV content
- recruiter messages
- job application notes
- personal notes

Do not push this repository until:

- screenshot evidence exists in `docs/images/`
- README displays the evidence
- private documents remain untracked
- Terraform state/plan files are absent from Git
- secrets scan is clean
