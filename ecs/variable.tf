variable "vpc_id" {
  type = string
}

variable "private_subnet_cidr_blocks" {
  type = list(string)
}

variable "private_vpc_zone_ids" {
  type = list(string)
}
