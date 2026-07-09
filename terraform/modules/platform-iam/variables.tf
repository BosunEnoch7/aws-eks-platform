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

variable "tags" {
  description = "Additional tags applied to supported resources."
  type        = map(string)
  default     = {}
}

