variable "aws_region" {
  description = "AWS Region in which the Terraform state bucket is created."
  type        = string
  default     = "eu-west-1"

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS Region identifier."
  }
}

variable "aws_profile" {
  description = "Named AWS CLI profile used only for local bootstrap operations."
  type        = string
  default     = "aws-eks-platform-dev"

  validation {
    condition     = length(trimspace(var.aws_profile)) > 0
    error_message = "aws_profile must not be empty."
  }
}

variable "owner" {
  description = "Owner tag applied to supported bootstrap resources."
  type        = string
  default     = "Olatubosun Enoch David"
}

variable "monthly_budget_amount_usd" {
  description = "Account-level monthly cost budget in US dollars."
  type        = number
  default     = 50

  validation {
    condition     = var.monthly_budget_amount_usd > 0
    error_message = "monthly_budget_amount_usd must be greater than zero."
  }
}

variable "budget_notification_email" {
  description = "Email address that receives AWS Budget notifications."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.budget_notification_email))
    error_message = "budget_notification_email must be a valid email address."
  }
}

