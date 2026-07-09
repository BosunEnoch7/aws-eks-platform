output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_security_group_id" {
  description = "Security group created by EKS for control-plane communication."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_group_arn" {
  description = "ARN of the managed system node group."
  value       = aws_eks_node_group.system.arn
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider used by IRSA roles."
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "oidc_provider_url" {
  description = "Issuer URL represented by the IAM OIDC provider."
  value       = aws_iam_openid_connect_provider.cluster.url
}

output "vpc_cni_role_arn" {
  description = "IRSA role used by the Amazon VPC CNI add-on."
  value       = aws_iam_role.vpc_cni.arn
}
