terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source = "./vpc"
}

module "ecs" {
  source = "./ecs"
  vpc_id = module.vpc.vpc_id
  private_subnet_cidr_blocks = module.vpc.private_subnet_cidr_blocks
  private_vpc_zone_ids = module.vpc.private_vpc_zone_ids
}

module "vacgom-backend" {
  source = "./vacgom-backend"
  vacgom-container-image = var.vacgom-container-image
}
