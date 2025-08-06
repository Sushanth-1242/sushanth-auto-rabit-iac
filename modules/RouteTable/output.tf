output "public_route_table_id" {
  value       = aws_route_table.public_route_table.id
  description = "The ID of the public route table"
}

output "private_route_table_id" {
  value       = aws_route_table.private_route_table.id
  description = "The ID of the private route table"
}