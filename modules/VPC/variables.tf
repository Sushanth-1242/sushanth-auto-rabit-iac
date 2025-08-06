# VPC CIDR block
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

# Availability Zones
variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}

# Subnet CIDR blocks (one for each subnet)
variable "subnet_cidr_blocks" {
  description = "The CIDR blocks for the public and private subnets"
  type        = list(string)
}

# Tags for VPC
variable "vpc_tags" {
  description = "Tags for the VPC"
  type        = map(string)
}

# Tags for Subnets
variable "subnet_tags" {
  description = "Tags for subnets"
  type        = map(string)
}

# VPC name (to be passed from root main.tf)
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

