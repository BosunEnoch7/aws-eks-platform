# Platform Architecture

## Delivery and runtime architecture

```mermaid
flowchart TB
    developer[Developer] -->|Push or pull request| github[GitHub]
    github --> actions[GitHub Actions]
    actions -->|OIDC authentication| iam[AWS IAM]
    actions -->|Push immutable image| ecr[Amazon ECR]
    actions -->|Update image reference| desired[Git desired state]

    desired -->|Watch and reconcile| argocd[Argo CD]
    argocd --> deployment[Application Deployment]
    ecr -->|Pull image| pods[Application Pods]
    deployment --> pods

    internet[Client] --> nlb[AWS Network Load Balancer]
    nlb --> nginx[NGINX Ingress Controller]
    nginx --> service[ClusterIP Service]
    service --> pods

    hpa[Horizontal Pod Autoscaler] -->|Adjust replicas| deployment
    metrics[Prometheus] -->|Metrics API input| hpa
    pods -->|Application metrics| metrics
    metrics --> grafana[Grafana]
    metrics --> alertmanager[Alertmanager]

    secrets[AWS Secrets Manager] -->|IRSA-authorised retrieval| secretop[Secrets integration]
    secretop --> pods

    pods -->|Container logs| fluentbit[Fluent Bit]
    fluentbit --> cloudwatch[CloudWatch Logs]
    eks[EKS control plane] -->|Control-plane logs| cloudwatch

    lbc[AWS Load Balancer Controller] -->|Reconcile Service| nlb
```

## Infrastructure ownership

```mermaid
flowchart LR
    terraform[Terraform] --> vpc[VPC and subnets]
    terraform --> eks[Amazon EKS]
    terraform --> nodes[Managed node groups]
    terraform --> ecr[Amazon ECR]
    terraform --> iam[IAM and OIDC]
    terraform --> logs[CloudWatch configuration]

    git[Git desired state] --> argocd[Argo CD]
    argocd --> workloads[Kubernetes workloads]
    workloads --> controllers[Kubernetes and AWS controllers]
    controllers --> generated[AWS load balancer and runtime state]
```

## Boundary notes

- Terraform does not manage application Pods directly.
- GitHub Actions produces artifacts but is not the normal cluster deployment
  authority.
- Argo CD reconciles Kubernetes desired state but does not replace Terraform as
  the owner of foundational AWS infrastructure.
- The AWS Load Balancer Controller owns load balancers that are generated from
  Kubernetes resources.
- Prometheus metrics and CloudWatch logs have complementary operational roles.

