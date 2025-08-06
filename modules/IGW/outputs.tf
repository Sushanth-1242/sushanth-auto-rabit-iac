output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "The ID of the Internet Gateway"
}

output "internet_gateway_name" {
  value       = var.internet_gateway_name
  description = "The name of the Internet Gateway"
}