module "vpc" {
  source            = "github.com/kiran6055/tf-module-vpc"
  env               = var.env
  default_vpc_id    = var.default_vpc_id

  for_each                = var.vpc
  cidr_block              = each.value.cidr_block
  public_subnets          = each.value.public_subnets
  private_subnets         = each.value.private_subnets
  availability_zone       = each.value.availability_zone
}

module "docdb" {
  source = "github.com/kiran6055/tf-module-docdb"
  env    = var.env

  for_each   = var.docdb
  subnet_ids = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), "private_subnets_ids", null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id     = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)
  engine_version = each.value.engine_version
  number_of_instances = each.value.number_of_instances
  instance_class = each.value.instance_class
}

module "RDS" {
  source = "github.com/kiran6055/tf-module-RDS"
  env    = var.env

  for_each             = var.rds
  subnet_ids           = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), "private_subnets_ids", null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id               = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr           = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)
  engine_version       = each.value.engine_version
  engine               = each.value.engine
  number_of_instances  = each.value.number_of_instances
  instance_class       = each.value.instance_class
}

module "elasticache" {
  source = "github.com/kiran6055/tf-module-elasticache"
  env    = var.env

  for_each        = var.elasticache
  subnet_ids      = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), "private_subnets_ids", null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id          = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr      = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)
  num_cache_nodes = each.value.num_cache_nodes
  node_type       = each.value.node_type
  engine_version  = each.value.engine_version
}

module "rabbitmq" {
  source              = "github.com/kiran6055/tf-module-rabbitmq"
  env                 = var.env
  bastion_cidr        = var.bastion_cidr
  monitor_cidr        = var.monitor_cidr

  for_each             = var.rabbitmq
  subnet_ids           = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), "private_subnets_ids", null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id               = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr           = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)
#  engine_version       = each.value.engine_version
#  engine_type          = each.value.engine_type
#  host_instance_type   = each.value.host_instance_type
#  deployment_mode      = each.value.deployment_mode

}

# concat function is used for app and web subntes for available if there are any two subnets required we need to use concat function each.value.internal ? is a condition used to get values for internet and to change subntes

module "alb" {
  source            = "github.com/kiran6055/tf-module-alb"
  env               = var.env


  for_each             = var.alb
  subnet_ids           = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), each.value.subnets_type, null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id               = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr           = each.value.internal ? concat(lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "web", null), "cidr_block", null), lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)): ["0.0.0.0/0"]
  subnets_name         = each.value.subnets_name
  internal             = each.value.internal
  dns_domain           = each.value.dns_domain


}

# we are using this for muttable and immutable approach onl
#module "apps" {
#  source = "github.com/kiran6055/tf-module-app"
#  env    = var.env

#  depends_on        = [module.docdb, module.RDS, module.elasticache, module.rabbitmq, module.alb]
#  for_each          = var.apps
#  subnet_ids        = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), each.value.subnets_type, null), each.value.subnets_name, null), "subnet_ids", null)
#  vpc_id            = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
#  allow_cidr        = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), each.value.allow_cidr_subnets_type, null), each.value.allow_cidr_subnets_name, null), "cidr_block", null)
#  alb               = lookup(lookup(module.alb, each.value.alb, null), "dns_name", null)
#  listener          = lookup(lookup(module.alb, each.value.alb, null), "listener", null)
#  alb_arn          = lookup(lookup(module.alb, each.value.alb, null), "alb_arn", null)
#  component         = each.value.component
#  app_port          = each.value.app_port
#  max_size          = each.value.max_size
#  min_size          = each.value.min_size
#  desired_capacity  = each.value.desired_capacity
#  instance_type     = each.value.instance_type
#  listener_priority = each.value.listener_priority
#  bastion_cidr      = var.bastion_cidr
#  monitor_cidr      = var.monitor_cidr


#}

#output "docdb" {
#  value = module.docdb
#}


#creating a minikube using terraform
# element in aws_subnet_id is used for to pick the first number where we gave 0 also in the end


module "minikube" {
  source = "github.com/scholzj/terraform-aws-minikube"

  aws_region        = "us-east-1"
  cluster_name      = "minikube"
  aws_instance_type = "t3.medium"
  ssh_public_key    = "~/.ssh/id_rsa.pub"
  aws_subnet_id     = element(lookup(lookup(lookup(lookup(module.vpc,main, null), public_subnets, null), public, null), "subnet_ids", null), 0)

  //ami_image_id        = data.aws_ami.ami.id
  hosted_zone         = var.hosted_zone
  hosted_zone_private = false

  tags = {
    Application = "Minikube"
  }

  addons = [
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/storage-class.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/heapster.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/dashboard.yaml",
    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/external-dns.yaml"
  ]
}



output "MINIKUBE_SERVER" {
  value = "ssh centos@${module.minikube.public_ip}"
}

output "KUBE_CONFIG" {
  value = "scp centos@${module.minikube.public_ip}:/home/centos/kubeconfig ~/.kube/config"
}

