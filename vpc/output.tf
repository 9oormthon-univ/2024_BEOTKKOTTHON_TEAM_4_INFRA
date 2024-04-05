output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "private_vpc_zone_ids" {
  value = module.vpc.private_subnets
}
