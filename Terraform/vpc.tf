#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

data "aws_availability_zones" "azs" {}
resource "aws_vpc" "myapp-vpc" {
cidr_block      = var.vpc_cidr_block

  tags = tomap({
    "Name"                                      = "myapp-eks-cluster",
    "kubernetes.io/cluster/${var.myapp-eks-cluster}" = "shared",
  })
}

resource "aws_subnet" "myapp" {
  count = 2

  availability_zone       = data.azs.available.names
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.myapp-vpc.id

  tags = tomap({
    "Name"                                      = "myapp-eks-cluster",
    "kubernetes.io/cluster/${var.myapp-eks-cluster}" = "shared",
  })
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

  subnet_id      = aws_subnet.myapp.id
  route_table_id = aws_route_table.myapp.id
}
