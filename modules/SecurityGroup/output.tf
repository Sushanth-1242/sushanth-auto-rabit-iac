# Output the security group ids
output "security_group_ids" {
  description = "List of Security Group IDs"
  value = aws_security_group.sg.*.id
}
