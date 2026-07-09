output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "IPv4 CIDR of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets in Availability Zone order."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets in Availability Zone order."
  value       = aws_subnet.private[*].id
}

output "availability_zones" {
  description = "Availability Zones used by the VPC."
  value       = var.availability_zones
}

output "nat_gateway_ids" {
  description = "IDs of the NAT gateways; empty when NAT is disabled."
  value       = aws_nat_gateway.this[*].id
}

