variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster IAM OIDC provider."
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the cluster IAM OIDC provider."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace that owns the workload service account."
  type        = string
}

variable "service_account" {
  description = "Kubernetes service account allowed to assume the application IAM role."
  type        = string
}

variable "secret_name" {
  description = "AWS Secrets Manager secret name for application runtime configuration."
  type        = string
}

variable "recovery_window_in_days" {
  description = "Secrets Manager recovery window for deleted secrets."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags applied to supported resources."
  type        = map(string)
  default     = {}
}
