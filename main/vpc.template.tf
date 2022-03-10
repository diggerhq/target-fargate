
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availabilityZone_a = data.aws_availability_zones.available.names[0]
  availabilityZone_b = data.aws_availability_zones.available.names[1]
  availabilityZone_c = data.aws_availability_zones.available.names[0]
  availabilityZone_d = data.aws_availability_zones.available.names[1]
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

variable "publicSubnetcCIDRblock" {
  default = "10.0.5.0/24"
}

variable "publicSubnetdCIDRblock" {
  default = "10.0.6.0/24"
}

variable "destinationCIDRblock" {
  default = "0.0.0.0/0"
}

variable "ingressCIDRblock" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "egressCIDRblock" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "mapPublicIP" {
  default = false
}

variable "disable_nat_gateway" {
  description = ""
  default = {{ (environment_config.disable_nat or true) | lower }}
}

variable "nat_gateway_destination_cidr_block" {
  description = "Used to pass a custom destination route for private NAT Gateway. If not specified, the default 0.0.0.0/0 is used as a destination route."
  type        = string
  default     = "0.0.0.0/0"
}

# this config allows creating subbnets in an existing VPC
{% if environment_config.vpc_id %}
data "aws_vpc" "vpc" {
  id = "{{environment_config.vpc_id}}"
}

locals {
  vpc = data.aws_vpc.vpc
}
{% else %}
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
  tags = {
    Name = "${var.ecs_cluster_name}-${var.environment}-VPC"
  }

  lifecycle {
    ignore_changes = [tags["Changed"]]
  }  
}

locals {
  vpc = aws_vpc.vpc
}
{% endif %}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = local.vpc.id
  cidr_block              = var.publicSubnetaCIDRblock
  map_public_ip_on_launch = true
  availability_zone       = local.availabilityZone_a
  tags = {
    Name = "${var.app}-${var.environment}-public_vpc_subneta"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = local.vpc.id
  cidr_block              = var.publicSubnetbCIDRblock
  map_public_ip_on_launch = true
  availability_zone       = local.availabilityZone_b
  tags = {
    Name = "${var.app}-${var.environment}-public_vpc_subnetb"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = local.vpc.id
  cidr_block              = var.publicSubnetcCIDRblock
  map_public_ip_on_launch = true
  availability_zone       = local.availabilityZone_c
  tags = {
    Name = "${var.app}-${var.environment}-public_vpc_subnetc"
  }
}

resource "aws_subnet" "public_subnet_d" {
  vpc_id                  = local.vpc.id
  cidr_block              = var.publicSubnetdCIDRblock
  map_public_ip_on_launch = true
  availability_zone       = local.availabilityZone_d
  tags = {
    Name = "${var.app}-${var.environment}-public_vpc_subnetd"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = local.vpc.id
  cidr_block              = var.privateSubnetaCIDRblock
  map_public_ip_on_launch = false
  availability_zone       = local.availabilityZone_a
  tags = {
    Name = "${var.app}-${var.environment}-private_vpc_subneta"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = local.vpc.id
  cidr_block              = var.privateSubnetbCIDRblock
  map_public_ip_on_launch = false
  availability_zone       = local.availabilityZone_b
  tags = {
    Name = "${var.app}-${var.environment}-private_vpc_subnetb"
  }
}

# if user is attaching to existing VPC we assume they already have a gateway attached!
{% if environment_config.vpc_id %}
  data "aws_internet_gateway" "vpc_ig" {
    filter {
      # filter by vpc ID
      name   = "attachment.vpc-id"
      values = ["{{environment_config.vpc_id}}"]
    }
  }

  locals {
    vpc_ig = data.aws_internet_gateway.vpc_ig
  }
{% else %}
  resource "aws_internet_gateway" "vpc_ig" {
    vpc_id = local.vpc.id
    tags = {
      Name = "${var.app} Internet Gateway"
    }
  }

  locals {
    vpc_ig = aws_internet_gateway.vpc_ig
  }
{% endif %}

resource "aws_route_table" "route_table_public" {
  vpc_id = local.vpc.id

  # Note: "local" VPC record is implicitly specified
  tags = {
    Name = "${var.app}-${var.environment} Public Route Table"
  }
}

resource "aws_route" "gateway_route" {
  route_table_id = aws_route_table.route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = local.vpc_ig.id
}

resource "aws_route_table_association" "publica" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "publicb" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "publicc" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "publicd" {
  subnet_id      = aws_subnet.public_subnet_d.id
  route_table_id = aws_route_table.route_table_public.id
}

{% if environment_config.disable_nat is defined and environment_config.disable_nat is sameas false %}

//// NAT GATEWAY

locals {
  nat_gateway_ips = try(aws_eip.nat_eip[*].id, [])
}

resource "aws_route_table" "route_table_private" {
  vpc_id = local.vpc.id

  tags = {
    Name = "${var.app}-${var.environment} Private Route Table"
  }
}

resource "aws_eip" "nat_eip" {
  count = var.disable_nat_gateway ? 0 : 1

  vpc = true
  tags = var.tags
}

resource "aws_nat_gateway" "nat_gateway" {
  count = var.disable_nat_gateway ? 0 : 1

  allocation_id = element(local.nat_gateway_ips, 0)
  subnet_id = aws_subnet.public_subnet_a.id
  tags = var.tags
  depends_on = [local.vpc_ig]
}

resource "aws_route" "private_nat_gateway_route" {
  count = var.disable_nat_gateway ? 0 : 1

  route_table_id         = element(aws_route_table.route_table_private[*].id, count.index)
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  nat_gateway_id         = element(aws_nat_gateway.nat_gateway[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

# Private Route to Private Route Table for Private Subnets
resource "aws_route_table_association" "private" {
  for_each  = {a= aws_subnet.private_subnet_a.id, b = aws_subnet.private_subnet_b.id}
  subnet_id = each.value
  route_table_id = aws_route_table.route_table_private.id
}

{% endif %}

# output the vpc ids
output "main_vpc_id" {
  value = local.vpc.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_subnet_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_subnet_b.id
}

output "public_subnet_c_id" {
  value = aws_subnet.public_subnet_c.id
}

output "public_subnet_d_id" {
  value = aws_subnet.public_subnet_d.id
}
