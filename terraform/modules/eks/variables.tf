variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string

  validation {
    condition     = can(regex("^[0-9A-Za-z][0-9A-Za-z_-]*$", var.cluster_name))
    error_message = "cluster_name must be a valid EKS cluster name."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes minor version for the EKS control plane and nodes."
  type        = string
  default     = "1.35"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the EKS control plane ENIs and nodes."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "EKS requires private subnets in at least two Availability Zones."
  }
}

variable "cluster_public_access_cidrs" {
  description = "Explicit IPv4 CIDRs allowed to reach the public EKS API endpoint."
  type        = list(string)

  validation {
    condition = (
      length(var.cluster_public_access_cidrs) > 0 &&
      alltrue([for cidr in var.cluster_public_access_cidrs : can(cidrhost(cidr, 0))]) &&
      !contains(var.cluster_public_access_cidrs, "0.0.0.0/0")
    )
    error_message = "Provide at least one valid restricted CIDR; 0.0.0.0/0 is prohibited."
  }
}

variable "cluster_admin_principal_arn" {
  description = "Federated IAM role ARN granted initial EKS cluster administration."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.cluster_admin_principal_arn))
    error_message = "cluster_admin_principal_arn must be an IAM role ARN, not a user ARN."
  }
}

variable "control_plane_log_retention_days" {
  description = "CloudWatch retention for EKS control-plane logs."
  type        = number
  default     = 30
}

variable "node_instance_types" {
  description = "Allowed EC2 instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  description = "Minimum number of managed nodes."
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Initial desired number of managed nodes."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of managed nodes."
  type        = number
  default     = 3
}

variable "enable_vpc_cni_network_policy" {
  description = "Enable Amazon VPC CNI enforcement for Kubernetes NetworkPolicy resources."
  type        = bool
  default     = true
}

variable "enable_cloudwatch_observability" {
  description = "Install the Amazon CloudWatch Observability EKS add-on for container logs and CloudWatch telemetry."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to supported resources."
  type        = map(string)
  default     = {}
}
