# Terraform Bootstrap

This root module creates the minimum safety and state resources required before
the platform infrastructure is managed remotely:

- A globally unique S3 state bucket
- S3 versioning for state recovery
- Server-side encryption with Amazon S3 managed keys
- S3 Block Public Access and bucket-owner-enforced ownership
- A policy denying non-TLS access
- An account-level monthly AWS Budget with 50%, 80%, and forecasted 100% alerts
- An IAM role used as the initial EKS cluster administrator principal

## Why this module starts with local state

Terraform cannot use an S3 backend before the bucket exists. This bootstrap
therefore begins with local state. The file is ignored by Git and must be
handled as sensitive operational data.

After the bucket exists, later Terraform root modules use the S3 backend with
native S3 lockfiles. DynamoDB locking is not created because HashiCorp has
deprecated that mechanism.

The bootstrap state can later be migrated into its own key in the bucket after
carefully removing the bootstrap paradox. That migration will be documented
and tested before it is performed.

## Security decisions

- `prevent_destroy` protects the state bucket from an ordinary Terraform
  destroy.
- Bucket versioning provides recovery from overwritten state.
- Public access is blocked at all supported S3 controls.
- HTTP requests are denied.
- Credentials are supplied through the named AWS profile, not variables.
- The notification email is sensitive and belongs only in an ignored
  `terraform.tfvars` file or a temporary `TF_VAR_` environment variable.
- EKS administrator access is granted to an IAM role rather than binding the
  Kubernetes cluster directly to a long-lived IAM user.

SSE-S3 is selected for this learning environment because it provides encryption
at rest without a KMS key charge or extra key-policy dependency. A dedicated
customer-managed KMS key is a valid stricter production option.

## Preconditions

Do not apply this module until:

1. `aws-eks-platform-dev` authenticates to the intended account.
2. The account ID has been manually verified.
3. The Budget notification email and amount are approved.
4. The operator understands that even bootstrap S3 usage can incur a small
   charge.

## Planned workflow

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
# Replace the placeholder email and review every value.

$env:AWS_PROFILE = "aws-eks-platform-dev"
$env:AWS_REGION = "eu-west-1"
aws sts get-caller-identity

terraform init
terraform fmt -check
terraform validate
terraform plan
```

`terraform apply` is intentionally excluded from the automatic workflow until
the plan, identity, and cost notification destination are reviewed.

## EKS admin role

The bootstrap module creates `aws-eks-platform-eks-cluster-admin` and trusts the
current AWS caller to assume it. The dev EKS module then grants this role
cluster-admin access through an EKS access entry.

Why not bind the cluster directly to the IAM user? Roles are easier to rotate,
audit, and later replace with IAM Identity Center or another operator identity.

## S3 backend shape for later modules

Later root modules will use partial backend configuration similar to:

```hcl
terraform {
  backend "s3" {
    key          = "environments/dev/terraform.tfstate"
    use_lockfile = true
    encrypt      = true
  }
}
```

Bucket and Region will be passed during `terraform init`; credentials will
remain in the AWS profile rather than backend files.

## References

- [HashiCorp S3 backend and native locking](https://developer.hashicorp.com/terraform/language/backend/s3)
- [Amazon S3 Block Public Access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)
- [AWS Budgets creation guidance](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-create.html)
