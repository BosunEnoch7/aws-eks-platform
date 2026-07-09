# ADR-001: EKS Platform Operating Model and Responsibility Boundaries

- Status: Accepted
- Date: 2026-07-04
- Decision owners: Olatubosun Enoch David and platform engineering

## Context

This project must demonstrate production-inspired Kubernetes operations without
hiding the important mechanisms behind a fully automated cluster mode. It also
needs clear ownership boundaries so that Terraform, Helm, GitHub Actions, and
Argo CD do not compete to manage the same resources.

The platform must balance four concerns:

1. Educational depth
2. Production credibility
3. Security and reliability
4. A cost that can be controlled in a learning account

## Decision

### 1. Use EKS Standard with managed node groups

AWS will manage the Kubernetes control plane. EKS managed node groups will
provide the initial data plane.

This exposes node capacity, scheduling, add-ons, scaling, and upgrade decisions
for learning while avoiding the undifferentiated work of manually joining EC2
instances to the cluster.

EKS Auto Mode and Karpenter remain future comparison exercises.

### 2. Terraform owns AWS infrastructure

Terraform will manage the VPC, subnets, EKS cluster, managed node groups, ECR,
IAM roles, AWS-side logging configuration, and supporting AWS resources.

Kubernetes controllers may create AWS resources only where reconciliation from
a Kubernetes object is their intended responsibility. The principal example is
the AWS Load Balancer Controller creating a load balancer from a Service.

### 3. Helm packages Kubernetes applications

The sample application and configurable platform packages will use Helm.
Templates will remain small and explicit so abstraction does not obscure the
Kubernetes resources being taught.

### 4. GitHub Actions owns continuous integration

CI will lint, test, scan, build, and publish container images. It will
authenticate to AWS through GitHub OIDC rather than stored IAM user access keys.

CI may propose or commit a change to the declared image reference, but it will
not normally run `kubectl apply` against the platform.

### 5. Argo CD owns continuous delivery

Argo CD will reconcile approved Git state into EKS. Git is the audit trail and
the source of deployment intent. Emergency manual actions must be documented and
then reconciled back into Git.

### 6. Use immutable container releases

ECR repositories will use immutable tags where practical, image scanning, and
lifecycle policies. Kubernetes releases will be traceable to a unique commit
and image digest.

Mutable tags such as `latest` will not identify a deployed production release.

### 7. Use NLB in front of NGINX Ingress

The initial request path will be:

```text
Internet -> AWS NLB -> NGINX Ingress -> ClusterIP Service -> application Pods
```

The AWS Load Balancer Controller will reconcile the NGINX controller's
`LoadBalancer` Service and provision the NLB. NGINX will own Layer 7 routing
inside the cluster.

A direct ALB Ingress is a valid, simpler AWS-native alternative. It is not the
initial path because the selected design intentionally demonstrates both AWS
load-balancer integration and a Kubernetes ingress controller. We will not
deploy both public patterns without a concrete requirement.

### 8. Use IRSA for workload access to AWS

Kubernetes service accounts will assume narrowly scoped IAM roles through
IAM Roles for Service Accounts. Node roles will not receive application
permissions.

EKS Pod Identity will be documented as a modern alternative and may be
evaluated later. IRSA is retained because it is an explicit project objective
and an important production pattern.

### 9. Keep secrets outside Git

AWS Secrets Manager will be the external source for sensitive application
values. An integration controller will synchronise or mount those values for
authorised workloads through IRSA.

No plaintext secret values will be committed to the repository or stored in CI
configuration.

### 10. Split observability responsibilities

Prometheus will collect Kubernetes and application metrics. Grafana will
visualise them, and Alertmanager will route actionable alerts. CloudWatch will
receive EKS control-plane and container logs and provide AWS-native operational
integration.

This intentionally avoids treating CloudWatch and Prometheus as competing
systems.

### 11. Separate development and production configuration

Reusable modules and charts will be shared, while environment composition and
values remain separate. A development environment may use lower-cost capacity;
production documentation will retain multi-AZ, redundancy, and stricter
security expectations.

Environment separation in this repository does not claim that directories
alone provide account-level isolation.

### 12. Design across multiple Availability Zones

The VPC, EKS control plane integration, worker capacity, and load-balancing
design will span at least two Availability Zones. Workloads will later use
topology spread and disruption controls where appropriate.

## Ownership boundaries

| Resource or concern | Authoritative owner |
|---|---|
| VPC, EKS, ECR, IAM, node groups | Terraform |
| Application Kubernetes package | Helm chart |
| Desired environment deployment state | Git |
| Cluster reconciliation | Argo CD |
| Image build and publication | GitHub Actions |
| AWS load balancer lifecycle | AWS Load Balancer Controller |
| Runtime replica reconciliation | Kubernetes controllers |
| External secret value | AWS Secrets Manager |

## Consequences

### Benefits

- Every resource has a clear lifecycle owner.
- Git provides a reviewable deployment audit trail.
- CI credentials can be short-lived.
- Workload AWS permissions can be isolated from node permissions.
- The platform exposes meaningful Kubernetes operations for learning.

### Costs and risks

- EKS, NAT gateways, load balancers, and worker nodes create a non-trivial
  baseline cost.
- NGINX plus the AWS Load Balancer Controller adds more operational components
  than direct ALB ingress.
- Standard EKS requires more add-on, node, and upgrade management than Auto
  Mode.
- A single learning cluster cannot reproduce every production isolation
  property.

These risks will be addressed through cost profiles, pinned component versions,
automated validation, documented teardown procedures, and explicit statements
about which controls are simulated rather than fully production-equivalent.

## Revisit triggers

Revisit this ADR if:

- EKS Auto Mode becomes necessary for an operating model comparison.
- Multiple teams require stronger cluster or AWS account isolation.
- NGINX no longer provides a feature needed beyond direct ALB ingress.
- Secret rotation requirements favour CSI-mounted secrets.
- Workload growth makes managed node groups insufficient and motivates
  Karpenter.

