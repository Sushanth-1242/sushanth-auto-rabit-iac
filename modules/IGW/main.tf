resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags   = var.igw_tags
  # Optionally, you can specify a name for the Internet Gateway
  # tags = merge(var.igw_tags, {"Name" = var.internet_gateway_name})
}


