variable "nat_gateway_name" {
  description = "The name of the NAT Gateway"
  type        = string
  default     = "my-nat-gateway"
}

variable "vpc_id" {
  description = "The ID of the VPC where the NAT Gateway will be created"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the NAT Gateway will reside"
  type        = string
}

# variable "elastic_ip" {
#   description = "Elastic IP for the NAT Gateway"
#   type        = string
# }

variable "nat_gateway_tags" {
  description = "Tags to apply to the NAT Gateway"
  type        = map(string)
  default     = {
    "Environment" = "Dev"
    "Owner"       = "Team"
  }
}
