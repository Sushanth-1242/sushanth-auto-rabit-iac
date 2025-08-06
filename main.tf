module "vpc" {
  source = "./modules/VPC"
  subnet_tags         = var.subnet_tags
  vpc_name            = "${var.aws_region}-${var.environment}-vpc-01"  # Example naming
  cidr_block          = var.vpc_cidr_block
  azs                 = var.azs
  subnet_cidr_blocks  = var.subnet_cidr_blocks  # Three CIDR blocks for 1 public and 2 private subnets
  vpc_tags            = var.tags
}

module "internet_gateway" {
  source = "./modules/IGW"

  vpc_id             = module.vpc.vpc_id
  internet_gateway_name = "${var.aws_region}-${var.environment}-igw-01"
  igw_tags           = var.tags
}

module "nat_gateway" {
  source = "./modules/NAT"

  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.public_subnet_id # Public subnet for NAT
  nat_gateway_name   = "${var.aws_region}-${var.environment}-nat-01"
  nat_gateway_tags   = var.tags
}

module "route_tables" {
  source = "./modules/RouteTable"

  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = [module.vpc.public_subnet_id]
  private_subnet_ids  = [module.vpc.private_subnet_1_id,module.vpc.private_subnet_2_id]
  internet_gateway_id = module.internet_gateway.internet_gateway_id
  nat_gateway_id      = module.nat_gateway.nat_gateway_id
  route_table_tags    = var.route_table_tags
}

module "security_groups" {
  source          = "./modules/SecurityGroup"
  vpc_id          = module.vpc.vpc_id
  sg_name_prefix  = ["bia-Frontend-web-SG-prod-01",  "Bia-backend-SG-01-Prod-01"]

  ingress_rules = [
    # First Security Group (custom rules)
    [
      { from_port = 8081, to_port = 8081, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 8081, to_port = 8081, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
    ],
    # Second Security Group (custom rules)
    [
      { from_port = 8000, to_port = 8000, protocol = "tcp", cidr_blocks = ["10.1.0.78/32"] },
      { from_port = 8761, to_port = 8761, protocol = "tcp", cidr_blocks = ["10.2.2.252/32"] },
      { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 8000, to_port = 8000, protocol = "tcp", cidr_blocks = ["10.0.0.0/16"] }
    ]
  ]

  egress_rules = [
    # First Security Group (custom rules)
    [
      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
    ],
    # Second Security Group (custom rules)
    [
      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
    ],
    # Third Security Group (custom rules)
    [
      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
    ],
    # Fourth Security Group (custom rules)
    [
      { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
    ]
  ]

  tags = {
    Environment = "Production"
    Project     = "BIA"
  }

}

module "Frontend_vm" {
  source = "./modules/EC2"
   
  security_group_ids = [module.security_groups.security_group_ids[0]]
  instance_name = "frontend-${var.aws_region}-${var.environment}-ec2-01"
  subnet_id = module.vpc.public_subnet_id
  key_name = var.key_name
  instance_type =var.instance_type
  ami_id = var.ami_id
}

module "backend_vm" {
  source = "./modules/EC2"
   
  security_group_ids = [module.security_groups.security_group_ids[1]]
  instance_name = "backend-${var.aws_region}-${var.environment}-ec2-01"
  subnet_id = module.vpc.public_subnet_id
  key_name = var.key_name
  instance_type =var.instance_type
  ami_id = var.ami_id
  ebs_size = 20
}
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "internet_gateway_id" {
  value = module.internet_gateway.internet_gateway_id
}

output "nat_gateway_id" {
  value = module.nat_gateway.nat_gateway_id
}

output "public_route_table_id" {
  value = module.route_tables.public_route_table_id
}

output "private_route_table_id" {
  value = module.route_tables.private_route_table_id
}

output "Backend_vm_ip" {
  value = module.backend_vm.instance_public_ip
}
output "Frontend_vm_ip" {
  value = module.Frontend_vm.instance_public_ip
}
