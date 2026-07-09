output "vpc_id" {
  description = "ID of the development VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by internet-facing load balancers."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by EKS managed nodes."
  value       = module.vpc.private_subnet_ids
}

output "availability_zones" {
  description = "Availability Zones selected for the development VPC."
  value       = module.vpc.availability_zones
}

output "nat_gateway_ids" {
  description = "NAT gateways serving private subnet egress."
  value       = module.vpc.nat_gateway_ids
}

output "ecr_repository_url" {
  description = "URL of the application ECR repository."
  value       = module.ecr.repository_url
}

output "eks_cluster_name" {
  description = "Name of the development EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_oidc_provider_arn" {
  description = "IAM OIDC provider used for IRSA."
  value       = module.eks.oidc_provider_arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "IRSA role used by the AWS Load Balancer Controller."
  value       = module.platform_iam.aws_load_balancer_controller_role_arn
}

output "application_runtime_secret_arn" {
  description = "AWS Secrets Manager secret ARN referenced by the application ExternalSecret."
  value       = module.workload_security.application_runtime_secret_arn
}

output "application_runtime_role_arn" {
  description = "IRSA role used by the application service account to read its runtime secret."
  value       = module.workload_security.application_runtime_role_arn
}
