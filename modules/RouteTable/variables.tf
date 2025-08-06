variable "vpc_id" {
  description = "The ID of the VPC where the route tables will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "internet_gateway_id" {
  description = "The ID of the Internet Gateway for the public subnet"
  type        = string
}

variable "nat_gateway_id" {
  description = "The ID of the NAT Gateway for the private subnets"
  type        = string
}

variable "route_table_tags" {
  description = "Tags to apply to the route tables"
  type        = map(string)
  default     = {
    "Environment" = "Dev"
    "Owner"       = "Team"
  }
}
