variable "aws_region" {
  description = "AWS region where the resources will be created"
  type        = string
}

variable "environment" {
  description = "The environment for the resources"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones for the subnets"
  type        = list(string)
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for the subnets"
  type        = list(string)
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}

# variable "elastic_ip" {
#   description = "Elastic IP for the NAT Gateway"
#   type        = string
# }

# variable "public_subnet_ids" {
#   description = "List of public subnet IDs"
#   type        = list(string)
# }

# variable "private_subnet_ids" {
#   description = "List of private subnet IDs"
#   type        = list(string)
# }

variable "route_table_tags" {
  description = "Tags to apply to the route tables"
  type        = map(string)
}

variable "subnet_tags" {
  description = "Tags for subnets"
  type        = map(string)
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

# Define the instance type (e.g., t2.micro, t3.medium, etc.)
variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Define the SSH key pair name
variable "key_name" {
  description = "The SSH key pair to use for the instance"
  type        = string
}

