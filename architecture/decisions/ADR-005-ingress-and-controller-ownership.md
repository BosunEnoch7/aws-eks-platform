# ADR-005: Ingress Architecture and Controller Ownership

- Status: Accepted for offline implementation
- Date: 2026-07-04
- Decision owners: Olatubosun Enoch David and platform engineering

## Context

The platform needs a controlled route from AWS networking into Kubernetes while
keeping cloud-resource permissions separate from application routing. The AWS
Load Balancer Controller and NGINX Ingress Controller solve different parts of
that path and must not compete to reconcile the same object.

## Decision

### Use an NLB in front of NGINX Ingress

The request path is:

```text
Client -> internet-facing AWS NLB -> ingress-nginx Pods
       -> application ClusterIP Service -> application Pods
```

The NGINX controller's `LoadBalancer` Service requests an NLB by setting
`loadBalancerClass: service.k8s.aws/nlb`. The AWS Load Balancer Controller
reconciles that Service into AWS resources.

Application Ingress objects use `ingressClassName: nginx`. They are reconciled
by NGINX, not by the AWS controller.

### Separate lifecycle ownership

| Concern | Owner |
|---|---|
| IAM policy and IRSA role | Terraform |
| Controller chart version and values | Git |
| Controller Helm releases | Argo CD |
| NLB lifecycle | AWS Load Balancer Controller |
| HTTP routing configuration | NGINX Ingress Controller |
| Application route definitions | Application Helm chart |

Terraform will not install Helm releases. This prevents a Terraform state
operation from becoming the normal application-delivery mechanism.

### Use IP targets for the NLB

The NLB registers ingress-nginx Pods as targets. This removes the extra
NodePort hop used by instance targets and avoids exposing a node-wide traffic
port as the primary data path.

### Run redundant controller replicas

Both controllers request two replicas with disruption protection and
anti-concentration preferences. Controllers are control loops: redundancy
protects reconciliation during node maintenance, although existing NLB traffic
can continue briefly when a controller is unavailable.

### Pin chart and application versions

- AWS Load Balancer Controller chart/application: `3.4.0`
- ingress-nginx chart: `4.15.1`
- ingress-nginx controller: `1.15.1`

Updates require release-note, CRD, IAM policy, and Kubernetes compatibility
review. Argo CD must not track an unbounded `latest` chart.

### Keep TLS termination out of the initial controller phase

Initial values expose HTTP only. TLS requires an approved domain, DNS strategy,
and certificate ownership decision. Adding an unverified certificate annotation
would make the example look complete while leaving the actual trust path
undefined.

## Consequences

### Benefits

- AWS permissions stay in one dedicated service account.
- Multiple applications can share one NLB and NGINX routing tier.
- Kubernetes HTTP routing remains portable beyond AWS.
- IP targets provide a direct NLB-to-Pod data path.
- Terraform and Argo CD retain non-overlapping responsibilities.

### Costs and risks

- Two controllers create more operational work than direct ALB Ingress.
- NGINX is now part of the application data path and needs scaling, monitoring,
  upgrades, and Pod disruption controls.
- A shared ingress tier can become a shared failure domain.
- Internet-facing NLB hourly and data-processing charges apply.
- Upstream controller IAM policy includes capabilities not used by the initial
  NLB-only path; optional controller features remain disabled and the policy is
  versioned for review.

## Alternatives considered

### Direct ALB Ingress

This is simpler for AWS-native HTTP routing and removes NGINX from the data
path. It was not chosen because the project explicitly aims to teach ingress
controller operation and portable Kubernetes routing.

### NGINX without AWS Load Balancer Controller

Relying on the legacy in-tree AWS service controller weakens lifecycle clarity
and omits the modern EKS load-balancer integration the project must demonstrate.

## References

- [AWS Load Balancer Controller installation](https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html)
- [AWS controller traffic routing](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
- [ingress-nginx AWS deployment guidance](https://kubernetes.github.io/ingress-nginx/deploy/)

