#########
# VPC
#########
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

###########
# IGW
###########

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

########################
# PUBLIC ROUTE TABLE
########################

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

resource "aws_route_table_association" "rt_pub_subnet" {
  subnet_id = aws_subnet.public_subnets.id
  route_table_id = aws_route_table.pub_rt.id
}
#######################
# NAT GATEWAY
#######################
module "label_eip" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "eip"
  attributes = ["main"]
}

resource "aws_eip" "nat_gateway" {
  domain = "vpc"
  tags = module.label_eip.tags
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.public_subnets.id
}

########################
# PRIVATE ROUTE TABLE
########################
module "label_rt_private" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "rt"
  attributes = ["private"]
}

resource "aws_route_table" "priv_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = module.label_rt_private.tags
}

resource "aws_route_table_association" "rt_priv_subnet" {
  subnet_id = aws_subnet.private_subnets.id
  route_table_id = aws_route_table.priv_rt.id
}

################
# PUBLIC SUBNET
################
module "label_public_subnet" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "subnet"
  attributes = ["public"]
}

resource "aws_subnet" "public_subnets" {
 vpc_id     = aws_vpc.main.id
 cidr_block = var.public_subnet_cidrs
 availability_zone = var.azs
 tags    = module.label_public_subnet.tags
}

################
# PRIVATE SUBNET
################

module "label_private_subnet" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "subnet"
  attributes = ["private"]
}

resource "aws_subnet" "private_subnets" {
 vpc_id     = aws_vpc.main.id
 cidr_block = var.private_subnet_cidrs
 availability_zone = var.azs
 tags    = module.label_private_subnet.tags
}