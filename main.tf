module "vpc" {
  source            = "github.com/kirankumar7163/tf-module-vpc"
  env               = var.env
  default_vpc_id    = var.default_vpc_id

  for_each                = var.vpc
  cidr_block              = each.value.cidr_block
  public_subnets          = each.value.public_subnets
  private_subnets         = each.value.private_subnets
  availability_zone       = each.value.availability_zone
}

module "docdb" {
  source = "github.com/kirankumar7163/tf-module-docdb"
  env    = var.env

  for_each   = var.docdb
  subnet_ids = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), "private_subnets_ids", null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id     = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)
  engine_version = each.value.engine_version
  number_of_instances = each.value.number_of_instances
  instance_class = each.value.instance_class
}

module "rds" {
  source     = "github.com/kirankumar7163/tf-module-rds"
  env        = var.env

  for_each   = var.rds
  subnet_ids = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), "private_subnets_ids", null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id     = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)
  engine_version       = each.value.engine_version
  engine               = each.value.engine
  number_of_instances  = each.value.number_of_instances
  instance_class       = each.value.instance_class
}

module "elasticache" {
  source = "github.com/kirankumar7163/tf-module-elasticache"
  env    = var.env

  for_each                = var.elasticache
  subnet_ids              = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), "private_subnets_ids", null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id                  = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr              = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)
  num_node_groups         = each.value.num_node_groups
  replicas_per_node_group = each.value.replicas_per_node_group
  node_type               = each.value.node_type
}

output "vpc" {
  value = module.vpc
}