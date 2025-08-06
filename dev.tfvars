aws_region   = "us-east-1"
environment    = ""
vpc_cidr_block = "10.0.0.0/16"
subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
azs = ["us-east-1b", "us-east-1c"]

tags = {
  "Environment" = "Dev"
  "Owner"       = "sushanth"
}

route_table_tags = {
  "Environment" = "Dev"
  "Owner"       = "Sushanth"
}
subnet_tags = {
  Environment = "dev"
  Project     = "MyApp"
}
#############################ec2################################
ami_id = "ami-084a7d336e816906b"
instance_type = "t3.micro"
key_name = "auto-rebit-poc"