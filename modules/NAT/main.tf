
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.subnet_id
  tags          = var.nat_gateway_tags

  # Optionally, you can specify a name for the NAT Gateway
  # tags = merge(var.nat_gateway_tags, {"Name" = var.nat_gateway_name})
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

