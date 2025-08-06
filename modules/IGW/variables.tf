variable "internet_gateway_name" {
  description = "The name of the Internet Gateway"
  type        = string
  default     = "my-internet-gateway"
}

variable "vpc_id" {
  description = "The ID of the VPC to attach the Internet Gateway to"
  type        = string
}

variable "igw_tags" {
  description = "Tags to apply to the Internet Gateway"
  type        = map(string)
  default     = {
    "Environment" = "Dev"
    "Owner"       = "Team"
  }
}
