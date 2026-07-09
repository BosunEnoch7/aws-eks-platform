# LinkedIn Post

> Status: Draft. Publish after deployment screenshots are captured.

I just completed the offline build of `aws-eks-platform`, a
production-inspired Kubernetes platform on Amazon EKS.

The goal was not to create a basic Kubernetes demo. I wanted to model how a
platform team would provision, deploy, secure, observe, and operate workloads on
AWS.

What I built:

- Terraform-managed AWS foundation for VPC, EKS, ECR, IAM, IRSA, and CloudWatch
- Helm-packaged FastAPI workload with probes, HPA, PDB, NetworkPolicy, and
  Prometheus integration
- Argo CD App-of-Apps GitOps model
- NGINX Ingress behind AWS load balancing
- AWS Secrets Manager integration using External Secrets Operator
- kube-prometheus-stack with Grafana, Alertmanager, ServiceMonitor, and
  PrometheusRule resources
- GitHub Actions CI/CD for tests, validation, Docker build, ECR push, and
  GitOps image tag updates

Three decisions I focused on:

1. Terraform owns AWS infrastructure; Argo CD owns Kubernetes desired state.
2. GitHub Actions publishes artifacts but does not deploy directly to the
   cluster.
3. Secrets stay outside Git; the repo contains references and access policy, not
   secret values.

The biggest lesson: Kubernetes platform engineering is mostly about boundaries.
Tool boundaries, identity boundaries, network boundaries, and ownership
boundaries.

Next step: deploy the platform after AWS identity and budget guardrails are in
place, then capture operational evidence from real cluster tests.
