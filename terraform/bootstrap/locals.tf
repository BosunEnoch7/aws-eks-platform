locals {
  project     = "aws-eks-platform"
  environment = "shared"

  state_bucket_name = "${local.project}-tfstate-${data.aws_caller_identity.current.account_id}-${var.aws_region}"

  common_tags = {
    Project     = local.project
    Environment = local.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

