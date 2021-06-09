
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availabilityZone_a = data.aws_availability_zones.available.names[0]
  availabilityZone_b = data.aws_availability_zones.available.names[1]
}


variable "instanceTenancy" {
  default = "default"
}

variable "dnsSupport" {
  default = true
}

variable "dnsHostNames" {
  default = true
}

variable "vpcCIDRblock" {
  default = "10.0.0.0/16"
}

variable "publicSubnetaCIDRblock" {
  default = "10.0.1.0/24"
}

variable "publicSubnetbCIDRblock" {
  default = "10.0.2.0/24"
}

variable "privateSubnetaCIDRblock" {
  default = "10.0.3.0/24"
}

variable "privateSubnetbCIDRblock" {
  default = "10.0.4.0/24"
}

variable "destinationCIDRblock" {
  default = "0.0.0.0/0"
}

variable "ingressCIDRblock" {
  type    = list
  default = ["0.0.0.0/0"]
}

variable "egressCIDRblock" {
  type    = list
  default = ["0.0.0.0/0"]
}
variable "mapPublicIP" {
  default = false
}


resource "aws_vpc" "vpc" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
  tags = {
    Name = "My VPC"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.publicSubnetaCIDRblock
  map_public_ip_on_launch = true
  availability_zone       = local.availabilityZone_a
  tags = {
    Name = "public_vpc_subneta"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.publicSubnetbCIDRblock
  map_public_ip_on_launch = true
  availability_zone       = local.availabilityZone_b
  tags = {
    Name = "public_vpc_subnetb"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.privateSubnetaCIDRblock
  map_public_ip_on_launch = false
  availability_zone       = var.availabilityZone_a
  tags = {
    Name = "private_vpc_subneta"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.privateSubnetbCIDRblock
  map_public_ip_on_launch = false
  availability_zone       = var.availabilityZone_b
  tags = {
    Name = "private_vpc_subnetb"
  }
}

resource "aws_internet_gateway" "vpc_ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.app} Internet Gateway"
  }
}


resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  # Note: "local" VPC record is implicitly specified

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.vpc_ig.id
  }

  tags = {
    Name = "My VPC Public Route Table"
  }
}


resource "aws_route_table_association" "publica" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "publicb" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.route_table_public.id
}

