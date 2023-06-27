#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Tables
#  * NAT Gateway
#

data "aws_availability_zones" "available" {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                           = var.Dev
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/elb"                  = "1"
  }
}

resource "aws_subnet" "myapp" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.myapp-vpc.id
}

resource "aws_internet_gateway" "myapp" {
  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    Name = "myapp-eks-cluster"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_nat_gateway" "myapp" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.myapp[0].id

  tags = {
    Name = "NAT Gateway"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "NAT EIP"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block        = "0.0.0.0/0"
    nat_gateway_id    = aws_nat_gateway.myapp.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.myapp[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.myapp[count.index].id
  route_table_id = aws_route_table.private.id
}

