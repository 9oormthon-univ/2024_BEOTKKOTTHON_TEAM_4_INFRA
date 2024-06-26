terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

data "aws_route53_zone" "vacgom-zone" {
  name = var.vacgom-zone
}

module "vpc" {
  source = "./vpc"
}

module "ecs" {
  source                     = "./ecs"
  vpc_id                     = module.vpc.vpc_id
  private_subnet_cidr_blocks = module.vpc.private_subnet_cidr_blocks
  private_vpc_zone_ids       = module.vpc.private_vpc_zone_ids
  public_subnet_ids          = module.vpc.public_subnet_ids
}

module "vacgom-backend" {
  depends_on = [module.ecs]

  source                      = "./vacgom-backend"
  vacgom-container-image      = var.vacgom-container-image
  vacgom-cluster-name         = module.ecs.vacgom_cluster_name
  vacgom-capacity-provider-id = module.ecs.vacgom_capacity_provider_id
  vacgom-alb-id               = module.ecs.alb_id
  vpc-id                      = module.vpc.vpc_id

  private-cidr-groups = module.vpc.private_subnet_cidr_blocks
  private-subnet-ids  = module.vpc.private_vpc_zone_ids
  public-cidr-groups  = module.vpc.public_subnet_cidr_blocks

  vacgom-db-password = var.vacgom-db-password
  vacgom-domain      = var.vacgom-domain
  vacgom-zone        = var.vacgom-zone
}

module "s3" {
  source        = "./s3"
  vacgom-zone   = data.aws_route53_zone.vacgom-zone.id
  vacgom-domain = var.vacgom-domain
}
