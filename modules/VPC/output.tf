output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public_subnet_01.id
}

output "public_subnet_2_id" {
  description = "The ID of the private subnet 1"
  value       = aws_subnet.public_subnet_02.id
}

output "private_subnet_2_id" {
  description = "The ID of the private subnet 2"
  value       = aws_subnet.private_subnet_1.id
}
