resource "aws_security_group" "sg" {
  count       = length(var.sg_name_prefix)
  name        = "${var.sg_name_prefix[count.index]}-sg"
  vpc_id      = var.vpc_id
  description = "Security group for ${var.sg_name_prefix[count.index]} instances"

  dynamic "ingress" {
    for_each = var.ingress_rules[count.index]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules[count.index]
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = var.tags
}


output "security_group_ids" {
  description = "List of security group IDs"
  value       = aws_security_group.sg[*].id
}
