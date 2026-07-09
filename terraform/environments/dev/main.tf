data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "../../modules/vpc"

  name               = "${local.project}-${local.environment}"
  vpc_cidr           = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)

  public_subnet_cidrs = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]

  private_subnet_cidrs = [
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24",
  ]

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  tags = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name               = "${local.project}/application"
  untagged_image_retention_days = 7
  tagged_image_retention_count  = 30

  tags = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name                    = "${local.project}-${local.environment}"
  kubernetes_version              = "1.35"
  private_subnet_ids              = module.vpc.private_subnet_ids
  cluster_public_access_cidrs     = var.cluster_public_access_cidrs
  cluster_admin_principal_arn     = var.cluster_admin_principal_arn
  node_instance_types             = var.node_instance_types
  enable_vpc_cni_network_policy   = true
  enable_cloudwatch_observability = true

  node_min_size     = 1
  node_desired_size = 1
  node_max_size     = 1

  tags = local.common_tags
}

module "platform_iam" {
  source = "../../modules/platform-iam"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  tags = local.common_tags
}

module "workload_security" {
  source = "../../modules/workload-security"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  namespace         = "aws-eks-platform"
  service_account   = "aws-eks-platform-api"
  secret_name       = "${local.project}/${local.environment}/application/runtime"

  tags = local.common_tags
}
