resource "aws_instance" "my_instance" {
  ami                      = var.ami_id
  instance_type            = var.instance_type
  key_name                 = var.key_name
  vpc_security_group_ids   = var.security_group_ids
  subnet_id                = var.subnet_id
  associate_public_ip_address = true
  user_data = filebase64("${path.module}/userdata.sh")
  tags = {
    Name = var.instance_name
  }

  # Define the root EBS volume size
  root_block_device {
    volume_size = var.ebs_size  # Reference the variable for desired size
    volume_type = "gp2"
    delete_on_termination = true
  }
}
