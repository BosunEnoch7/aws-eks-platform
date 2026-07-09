output "application_runtime_secret_arn" {
  description = "ARN of the application runtime secret."
  value       = aws_secretsmanager_secret.application_runtime.arn
}

output "application_runtime_role_arn" {
  description = "IRSA role ARN for the application runtime service account."
  value       = aws_iam_role.application_runtime.arn
}
