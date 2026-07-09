# Deployment Readiness Status

> Last updated during live deployment preflight.

## Completed preflight checks

- AWS CLI installed: `aws-cli/2.34.27`
- Terraform installed: `1.14.8`
- kubectl installed: `v1.34.1`
- Git remote configured: `https://github.com/BosunEnoch7/aws-eks-platform.git`
- Helm installed: `v4.2.2`
- Helm chart lint: passed
- Helm chart render with safe placeholder values: passed
- Terraform validation: passed in the offline build
- Python tests: passed in the offline build
- YAML validation: passed in the offline build
- Bootstrap Terraform apply: completed
- Bootstrap S3 state bucket versioning: verified enabled
- AWS Budget: verified healthy with `$5` monthly limit

## Remaining blockers before `terraform plan`

- Dev EKS plan must be regenerated after switching to one-node lab mode.
- Live EKS apply still requires explicit approval because it creates billable
  resources.

## Required user-provided values

```text
aws_profile = "aws-eks-platform-dev"
budget_notification_email = "<your-email>"
monthly_budget_amount_usd = 5
cluster_admin_principal_arn = "arn:aws:iam::<account-id>:role/<admin-role>"
cluster_public_access_cidrs = ["<your-public-ip>/32"]
```

Do not commit real `.tfvars` files. They are ignored by Git because they contain
account-specific deployment values.
