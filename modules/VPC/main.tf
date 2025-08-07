resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.vpc_tags, { Name = var.vpc_name })  # Set VPC name through tags
  instance_tenancy     = "default"
}

# Public Subnet
resource "aws_subnet" "public_subnet_01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_blocks[0]  # Public Subnet CIDR block
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true
  tags                    = merge(var.subnet_tags, { Name = "${var.vpc_name}-public-subnet-01" })
}

# Private Subnet 1
resource "aws_subnet" "public_subnet_02" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_blocks[1]  # Private Subnet 1 CIDR block
  availability_zone       = var.azs[1]
  map_public_ip_on_launch = false
  tags                    = merge(var.subnet_tags, { Name = "${var.vpc_name}-public-subnet-02" })
}

# Private Subnet 2
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_blocks[2]  # Private Subnet 2 CIDR block
  availability_zone       = var.azs[1]
  map_public_ip_on_launch = false
  tags                    = merge(var.subnet_tags, { Name = "${var.vpc_name}-private-subnet-02" })
}
