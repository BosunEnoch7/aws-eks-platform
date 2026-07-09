variable "aws_region" {
  description = "AWS Region for the development platform."
  type        = string
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "Named AWS CLI profile used for local Terraform operations."
  type        = string
  default     = "aws-eks-platform-dev"
}

variable "owner" {
  description = "Owner tag applied to supported resources."
  type        = string
  default     = "Olatubosun Enoch David"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR for the development VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "single_nat_gateway" {
  description = "Use one shared NAT gateway to reduce development cost."
  type        = bool
  default     = true
}

variable "cluster_public_access_cidrs" {
  description = "Restricted operator CIDRs allowed to access the EKS API."
  type        = list(string)
}

variable "cluster_admin_principal_arn" {
  description = "Federated IAM role granted initial cluster administration."
  type        = string
}

variable "node_instance_types" {
  description = "EC2 instance types used by the EKS system node group."
  type        = list(string)
  default     = ["t3.medium"]
}
