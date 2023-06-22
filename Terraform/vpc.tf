#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

data "aws_availability_zones" "available" {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                           = var.enviroment
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

resource "aws_route_table" "myapp" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp.id
  }
}

resource "aws_route_table_association" "myapp" {
  count = 2

  subnet_id = element(aws_subnet.myapp.*.id, 1)
  route_table_id = aws_route_table.myapp.id
}
