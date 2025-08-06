output "nat_gateway_id" {
  value       = aws_nat_gateway.nat_gateway.id
  description = "The ID of the NAT Gateway"
}

output "nat_gateway_name" {
  value       = var.nat_gateway_name
  description = "The name of the NAT Gateway"
}
