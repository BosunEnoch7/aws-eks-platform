locals {
  az_count          = length(var.availability_zones)
  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : local.az_count) : 0

  common_tags = merge(
    var.tags,
    {
      Module = "vpc"
    }
  )
}

