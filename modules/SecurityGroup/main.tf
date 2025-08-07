resource "aws_security_group" "sg" {
  for_each = toset(var.sg_name_prefix)

  name_prefix = each.key
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Output the security group IDs
output "security_group_ids" {
  description = "List of Security Group IDs"
  value = [for sg in aws_security_group.sg : sg.id]
}
