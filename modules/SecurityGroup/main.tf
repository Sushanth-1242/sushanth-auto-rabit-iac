resource "aws_security_group" "sg" {
  for_each = { for idx, rule in var.egress_rules : idx => rule }

  name_prefix = "${var.sg_name_prefix[each.key]}-sg"
  description = "Security group for ${var.sg_name_prefix[each.key]}"
  vpc_id      = var.vpc_id

  # HTTP access from anywhere
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Optional: Using the egress rules defined in the variable
  dynamic "egress" {
    for_each = each.value
    content {
      description = "All outbound traffic"
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(var.tags, {
    Name = "${var.sg_name_prefix[each.key]}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}
