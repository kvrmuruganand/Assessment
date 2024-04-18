module "label_vpc" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "vpc"
  attributes = ["main"]
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = module.label_vpc.tags
}

# =========================
# IGW
# =========================

module "label_igw" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "igw"
  attributes = ["main"]
}

resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main.id
 tags = module.label_igw.tags
}

module "label_rt_public" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "rt"
  attributes = ["public"]
}

resource "aws_route_table" "pub_rt" {
 vpc_id = aws_vpc.main.id

 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 tags = module.label_rt_public.tags
}
################
# SUBNETS
#################
data "aws_availability_zones" "available" {
  state = "available"
}

module "subnets" {
  source = "cloudposse/dynamic-subnets/aws"
  vpc_id              = aws_vpc.main.id
  igw_id              = [ aws_internet_gateway.gw.id ]
  ipv4_cidr_block     = [ var.vpc_cidr ]
  availability_zones  = [ data.aws_availability_zones.available.names[0] ]
  context = module.base_label.context
}