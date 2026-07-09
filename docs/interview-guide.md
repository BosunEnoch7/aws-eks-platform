# Interview Guide

> Status: Portfolio interview guide complete for the offline platform build.

## Strong answers

### 1. Why EKS instead of ECS?

ECS is simpler for AWS-only container orchestration, but EKS exposes the full
Kubernetes operating model: Helm, Argo CD, NetworkPolicy, HPA, controllers, CRDs,
and platform APIs. I chose EKS because the project goal was to deepen
Kubernetes and platform engineering skills, not only run containers.

### 2. Where is the boundary between Terraform and Argo CD?

Terraform owns AWS infrastructure and IAM: VPC, EKS, ECR, IRSA roles, and AWS
add-ons. Argo CD owns Kubernetes desired state: controllers, application chart,
dashboards, ServiceMonitor, and PrometheusRule resources. The boundary prevents
state drift and makes recovery clearer.

### 3. Why should CI not directly deploy to the cluster?

CI should validate and publish artifacts. CD should reconcile desired state.
GitHub Actions updates the GitOps image tag, then Argo CD deploys it. That gives
an audit trail and avoids giving CI broad Kubernetes admin authority.

### 4. Why NLB plus NGINX Ingress?

The AWS Load Balancer Controller provisions the AWS network load balancer, while
NGINX handles Kubernetes HTTP routing. This separates cloud load balancing from
application routing and keeps the app ingress model portable.

### 5. How does IRSA improve security?

IRSA maps a Kubernetes service account to a narrowly scoped IAM role. The app
can read only its runtime secret instead of inheriting permissions from the node
role. This reduces blast radius if a workload is compromised.

### 6. What is the difference between HPA and node autoscaling?

HPA changes pod replica count based on metrics. Node autoscaling changes the
amount of cluster compute. This project implements HPA and leaves Karpenter or
Cluster Autoscaler as a future improvement.

### 7. How does readiness protect a rolling update?

Kubernetes sends traffic only to ready pods. During rollout, the new pod must
pass readiness before the old pod is removed, especially because the Deployment
uses `maxUnavailable: 0`.

### 8. What happens when Git and live state diverge?

Argo CD detects drift. With self-heal enabled, it can reconcile live state back
to Git. The team should still inspect unexpected drift because it may reveal a
manual hotfix, controller issue, or bad desired state.

### 9. What is production-inspired but not production-equivalent?

The repo includes production patterns, but it is not production-equivalent until
it is deployed, load-tested, monitored with real traffic, secured with real
RBAC/branch protection, and validated with failure drills.

### 10. What would you improve next?

I would add Karpenter, VPC endpoints, policy-as-code admission, image scanning,
SBOMs, image signing, SLO/error-budget reporting, and multi-account separation.
