variable "repository_name" {
  description = "Name of the private ECR repository."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+(?:[._/-][a-z0-9]+)*$", var.repository_name))
    error_message = "repository_name must be a valid lowercase ECR repository name."
  }
}

variable "untagged_image_retention_days" {
  description = "Days before untagged images are expired."
  type        = number
  default     = 7

  validation {
    condition     = var.untagged_image_retention_days >= 1
    error_message = "untagged_image_retention_days must be at least one."
  }
}

variable "tagged_image_retention_count" {
  description = "Maximum number of tagged release images retained."
  type        = number
  default     = 30

  validation {
    condition     = var.tagged_image_retention_count >= 1
    error_message = "tagged_image_retention_count must be at least one."
  }
}

variable "tags" {
  description = "Additional tags applied to supported resources."
  type        = map(string)
  default     = {}
}

