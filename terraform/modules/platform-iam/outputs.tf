output "aws_load_balancer_controller_role_arn" {
  description = "IRSA role annotated onto the AWS Load Balancer Controller service account."
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "aws_load_balancer_controller_policy_arn" {
  description = "Versioned IAM policy used by the AWS Load Balancer Controller."
  value       = aws_iam_policy.aws_load_balancer_controller.arn
}

