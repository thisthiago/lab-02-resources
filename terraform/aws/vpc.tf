data "aws_availability_zones" "available" {}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${terraform.workspace}-vpc"
  cidr = var.vpc_cidr[terraform.workspace]
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets               = var.vpc_private_subnets[terraform.workspace]
  public_subnets                = var.vpc_public_subnets[terraform.workspace]
  manage_default_network_acl    = true
  manage_default_route_table    = true
  manage_default_security_group = true
  enable_nat_gateway            = true
  single_nat_gateway            = true
  one_nat_gateway_per_az        = false

  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true

  tags = local.common_tags
}

