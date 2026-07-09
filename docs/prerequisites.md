# Prerequisites and Workstation Setup

> Phase 3 defines readiness. It does not install software, create credentials,
> or provision AWS resources.

## Readiness gates

Phase 4 must not begin until all required gates are satisfied:

- [ ] A non-root AWS operator identity is available.
- [ ] MFA protects privileged AWS access.
- [ ] A named profile called `aws-eks-platform-dev` authenticates successfully.
- [ ] `aws sts get-caller-identity` returns the intended AWS account and role.
- [ ] The selected Region is confirmed as `eu-west-1`, or ADR-002 is amended.
- [ ] AWS Budget notifications exist before chargeable infrastructure.
- [ ] Required local CLIs are installed and version checks pass. Helm `4.2.2`
  is installed; a fresh terminal must confirm its PATH entry.
- [ ] Docker can build and run a local test container.
- [ ] GitHub repository permissions allow OIDC configuration in a later phase.
- [ ] No AWS keys, Terraform state, kubeconfig, or secrets are tracked by Git.

## Required toolchain

| Tool | Purpose | Project requirement |
|---|---|---|
| Git | Source control and GitOps history | Required |
| AWS CLI v2 | Identity checks, EKS kubeconfig, AWS diagnostics | Required |
| Terraform | AWS infrastructure lifecycle | Required |
| `kubectl` | Kubernetes inspection and controlled operations | Required |
| Helm | Package and release Kubernetes applications | Required |
| Docker | Build and test application images | Required |
| GitHub CLI | Repository and workflow diagnostics | Recommended |
| Argo CD CLI | GitOps diagnostics and operator workflows | Recommended |
| `eksctl` | EKS diagnostics and comparison workflows | Optional |

`eksctl` will not create the cluster because Terraform is the infrastructure
authority. Keeping it optional also prevents a second tool from silently owning
CloudFormation-based cluster resources.

## Version policy

The initial compatibility target is:

| Component | Initial policy |
|---|---|
| EKS Kubernetes | `1.35`, revalidated before creation |
| `kubectl` | Within one minor version of the EKS control plane |
| Terraform CLI | `>= 1.10, < 2.0` |
| AWS provider | Constrained in Terraform and committed lock file |
| Helm CLI | A currently supported Helm 3 or 4 release; exact version recorded after installation |
| Docker | A maintained release capable of BuildKit builds |
| AWS CLI | AWS CLI v2 |

We constrain major versions to avoid unexpected breaking changes but allow
reviewed patch updates for security and bug fixes.

## AWS authentication model

### Human access

Preferred order:

1. IAM Identity Center with temporary sessions
2. Role assumption from an existing federated identity
3. A tightly controlled IAM user only when temporary authentication is
   unavailable

The root user is reserved for account-level recovery and root-only tasks.

The named profile is deliberately explicit:

```powershell
$env:AWS_PROFILE = "aws-eks-platform-dev"
$env:AWS_REGION = "eu-west-1"
aws sts get-caller-identity
```

Before any mutating command, compare the returned account and ARN with the
expected project account. Do not paste the account ID into public screenshots.

### GitHub Actions access

GitHub Actions will later exchange its OIDC token for temporary AWS credentials.
The IAM trust policy will restrict at least:

- GitHub organisation or repository
- Branch or GitHub environment
- Token audience

Long-lived IAM user keys will not be stored as GitHub secrets for ordinary
deployment.

## Region strategy

The initial Region is `eu-west-1`.

Reasons:

- Broad AWS and EKS service availability
- Multiple Availability Zones
- Mature availability of common EC2 families and EKS add-ons
- Reasonable connectivity from Lagos

The final decision must still consider:

- Actual latency from intended users
- EC2 instance and quota availability
- Current EKS, EC2, NAT, load-balancer, and CloudWatch prices
- Data-residency requirements
- Cross-Region or cross-AZ transfer costs

Region is an architectural input. It must not be scattered as hard-coded values
through modules.

## AWS account safety

Before provisioning:

1. Enable root-user MFA and avoid root access for normal work.
2. Use a dedicated sandbox account if one is available.
3. Record the expected AWS account ID privately.
4. Create a monthly AWS Budget with multiple notification thresholds.
5. Confirm EKS, VPC, Elastic Load Balancing, and EC2 service quotas.
6. Enable appropriate account security and billing notifications.
7. Tag every supported resource with project, environment, owner, and
   managed-by metadata.
8. Plan teardown before creation.

AWS Budgets notify; they do not guarantee that spending stops. Cost controls
must also include small capacity, short log retention, lifecycle rules, and
prompt teardown.

## Cost guardrails

The learning environment will use these policies:

- One EKS cluster during active implementation
- EKS Kubernetes versions in standard support
- Small managed-node capacity with explicit maximums
- No duplicate public load balancers without a tested requirement
- Short CloudWatch retention during development
- ECR lifecycle rules for unreferenced images
- Cost-allocation tags on supported resources
- A written destroy procedure and post-destroy verification
- No unattended lab environment after the learning session unless explicitly
  required

NAT gateways, the EKS control plane, worker instances, load balancers, log
ingestion, and cross-AZ traffic are expected baseline cost drivers.

## Workstation verification

These commands are read-only:

```powershell
aws --version
terraform version
kubectl version --client
helm version --short
docker version
git --version
gh --version
argocd version --client
```

AWS identity verification is also read-only but requires an authenticated
profile:

```powershell
$env:AWS_PROFILE = "aws-eks-platform-dev"
$env:AWS_REGION = "eu-west-1"
aws sts get-caller-identity
```

## Secret-handling rules

Never commit:

- `.env` files containing credentials
- Terraform state or plan files
- Kubernetes kubeconfig files
- AWS credential or SSO cache files
- Docker authentication configuration
- Private keys
- Unencrypted Kubernetes Secret manifests
- Generated files containing account-specific secret values

The repository `.gitignore` is defense in depth. It does not replace reviewing
staged changes before every commit.

## Authoritative references

- [Amazon EKS Kubernetes version lifecycle](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)
- [AWS guidance for installing `kubectl` and `eksctl`](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
- [AWS guidance for Helm on EKS](https://docs.aws.amazon.com/eks/latest/userguide/helm.html)
- [Amazon EKS pricing](https://aws.amazon.com/eks/pricing/)
