data "aws_availability_zones" "azs" {}
module "myapp-vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "3.19.0"
  name            = "myapp-vpc"
  cidr            = var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets  = var.public_subnet_cidr_blocks
  azs             = data.aws_availability_zones.azs.names

resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    Name = "myapp-igw"
  }
}

resource "aws_nat_gateway" "myapp_nat" {
  allocation_id = var.nat_allocation_id
  subnet_id     = aws_subnet.kubernetes.io/cluster/myapp-eks-cluster.id

  tags = {
    Name = "myapp-nat"
  }
}

  tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/elb"                  = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"         = 1
  }
}
