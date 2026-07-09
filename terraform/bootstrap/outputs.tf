output "aws_account_id" {
  description = "AWS account in which bootstrap resources will be created."
  value       = data.aws_caller_identity.current.account_id
}

output "state_bucket_name" {
  description = "S3 bucket used by later Terraform root modules."
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_region" {
  description = "AWS Region containing the Terraform state bucket."
  value       = aws_s3_bucket.terraform_state.region
}

output "backend_configuration" {
  description = "Non-secret values needed by later S3 backend configurations."
  value = {
    bucket       = aws_s3_bucket.terraform_state.id
    region       = var.aws_region
    use_lockfile = true
  }
}

output "eks_cluster_admin_role_arn" {
  description = "IAM role ARN to use as the initial EKS cluster administrator principal."
  value       = aws_iam_role.eks_cluster_admin.arn
}
