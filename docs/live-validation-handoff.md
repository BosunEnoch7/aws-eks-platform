# Live Validation Handoff

Date: 2026-07-16  
Project: `aws-eks-platform`  
AWS account: `637739133052`  
Region: `eu-west-1`

## Current status

The project repository is built and production-inspired Kubernetes platform assets are present:

- Terraform-managed AWS foundation
- Amazon EKS infrastructure modules
- Amazon ECR repository configuration
- Sample FastAPI application
- Dockerfile and application metrics endpoint
- Helm chart with probes, ConfigMap, Service, HPA, NetworkPolicy, ServiceMonitor, and PrometheusRule templates
- GitOps manifests for Argo CD
- Platform add-on manifests for ingress, monitoring, external-secrets, and AWS Load Balancer Controller
- Documentation structure for security, cost, troubleshooting, deployment, operations, observability, and production-readiness guidance

## Live AWS validation completed

The live infrastructure was successfully created during validation:

- EKS cluster: `aws-eks-platform-dev`
- Managed node group: `system`
- Instance type: `t3.small`
- ECR repository: `637739133052.dkr.ecr.eu-west-1.amazonaws.com/aws-eks-platform/application`
- VPC and private/public subnets
- NAT Gateway
- EKS add-ons:
  - `vpc-cni`
  - `coredns`
  - `kube-proxy`
  - `amazon-cloudwatch-observability`
- IRSA-related IAM roles and policies
- Secrets Manager runtime secret
- CloudWatch EKS control-plane log group

The application image was also built and pushed:

```text
637739133052.dkr.ecr.eu-west-1.amazonaws.com/aws-eks-platform/application:0.1.0
sha256:b0c35b66f85f40a25dcd164d41a9a18fa84b0815fee17d394938f9ebc99c802d
```

## Why full app validation was stopped

The final Kubernetes app rollout was blocked by two operational issues:

1. The local public IP changed during the session, while the EKS public endpoint was locked to a `/32` CIDR. This temporarily caused `kubectl` timeouts.
2. The EKS cluster disappeared from AWS after being recreated, while Terraform state still remembered it. This created state drift.
3. CloudTrail later confirmed the EKS deletion was not automatic. The cluster was deleted by an AWS CLI `eks.delete-cluster` call from IAM user `bosun-admin`.

Most recent confirmed event:

```text
Event: DeleteCluster
Cluster: aws-eks-platform-dev
Time: 2026-07-16 16:50:39 Africa/Lagos
IAM user: bosun-admin
Source IP: 197.211.63.182
User agent: aws-cli ... md/command#eks.delete-cluster
```

Because live paid AWS resources were running, validation was stopped and cost-generating project resources were removed rather than repeatedly rebuilding.

## Cost safety status

Final checks confirmed:

- No `aws-eks-platform-dev` EKS cluster is live.
- No project NAT Gateway is live.
- No project Elastic IP remains allocated.
- No project EC2 instances were found running.
- No project load balancers were found.
- AWS Budget actual spend still reported `$0.00` at the time of the final check, although AWS billing can lag.

At the latest check, EKS returned an empty cluster list for `eu-west-1`.

## Important Terraform note

Terraform state may still contain resources that were manually removed for cost safety. Before rebuilding live infrastructure again, run a drift repair workflow:

```powershell
cd terraform/environments/dev
terraform plan
```

If Terraform reports deleted resources, allow it to recreate them only when you are ready for live AWS costs again.

## Safe resume path

When ready to continue live validation:

1. Stop any terminal, script, scheduled task, or Terraform process that may be running `aws eks delete-cluster`, `aws eks delete-nodegroup`, or `terraform destroy`.
2. Confirm the current public IP.
3. Update `terraform/environments/dev/terraform.tfvars`:

   ```hcl
   cluster_public_access_cidrs = ["CURRENT_PUBLIC_IP/32"]
   ```

4. Run:

   ```powershell
   cd terraform/environments/dev
   terraform plan
   terraform apply
   aws eks update-kubeconfig --name aws-eks-platform-dev --region eu-west-1 --profile aws-eks-platform-dev --role-arn arn:aws:iam::637739133052:role/aws-eks-platform-eks-cluster-admin
   kubectl get nodes -o wide
   kubectl get pods -A
   ```

5. Deploy the lightweight application manifest:

   ```powershell
   kubectl apply -f k8s/live-application-lite.yaml
   kubectl rollout status deployment/aws-eks-platform-api -n aws-eks-platform --timeout=180s
   ```

6. Validate:

   ```powershell
   kubectl port-forward svc/aws-eks-platform-api -n aws-eks-platform 8080:80
   ```

   Then test:

   ```text
   http://localhost:8080/
   http://localhost:8080/healthz
   http://localhost:8080/readyz
   http://localhost:8080/version
   http://localhost:8080/metrics
   ```

7. Capture screenshots/evidence.
8. Destroy live dev resources after evidence:

   ```powershell
   terraform destroy
   ```

## Mentor note

This project is still strong because it demonstrates real platform engineering problems:

- EKS endpoint CIDR access control
- Terraform remote backend recovery
- State drift after interrupted/deleted cloud resources
- Cost containment under live AWS constraints
- IRSA and OIDC lifecycle behavior
- Kubernetes Pod Security Admission interactions with injected observability containers
- Why production rollouts must be layered and validated incrementally

Those lessons are more realistic than a perfectly smooth tutorial deployment.
