locals {
  project     = "aws-eks-platform"
  environment = "dev"

  common_tags = {
    Project     = local.project
    Environment = local.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

