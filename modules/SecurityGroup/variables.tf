variable "vpc_id" {
  description = "VPC ID in which to create the security groups"
  type        = string
}

variable "sg_name_prefix" {
  description = "Name prefixes for security groups"
  type        = list(string)
}

variable "ingress_rules" {
  description = "List of ingress rules for each security group"
  type = list(list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })))
}

variable "egress_rules" {
  description = "List of egress rules for security groups"
  type = list(list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  })))
  default = [
    [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  ]
}


variable "tags" {
  description = "Tags to apply to security groups"
  type        = map(string)
  default     = {}
}
