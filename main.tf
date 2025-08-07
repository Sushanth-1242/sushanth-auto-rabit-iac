# Declare the user_data local value to use in EC2 instances
locals {
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user
    
    # Install AWS CLI
    yum install -y aws-cli
    
    # Login to ECR and pull your Flask app
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
    
    # Pull and run your Flask app
    docker pull ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/flask/app:latest
    docker run -d -p 80:5000 --name flask-app --restart unless-stopped ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/flask/app:latest
  EOF
}

module "vpc" {
  source = "./modules/VPC"
  subnet_tags         = var.subnet_tags
  vpc_name            = "${var.aws_region}-${var.environment}-vpc-01"
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
  public_subnet_ids   = [module.vpc.public_subnet_id, module.vpc.public_subnet_2_id]  # Reference to public subnet IDs
  private_subnet_ids  = [module.vpc.private_subnet_1_id]  # Reference to private subnet IDs
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
  instance_type = var.instance_type
  ami_id = var.ami_id
}

module "backend_vm" {
  source = "./modules/EC2"
   
  security_group_ids = [module.security_groups.security_group_ids[1]]
  instance_name = "backend-${var.aws_region}-${var.environment}-ec2-01"
  subnet_id = module.vpc.public_subnet_id
  key_name = var.key_name
  instance_type = var.instance_type
  ami_id = var.ami_id
  ebs_size = 20
}

module "application_load_balancer" {
  source = "./modules/ALB"

  # ALB Configuration - aligned with your naming convention
  alb_name               = "${var.aws_region}-${var.environment}-alb-01"
  vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = [module.vpc.public_subnet_id, module.vpc.public_subnet_2_id]  # Reference to your public subnets
  private_subnet_ids     = []  # No need for private subnets for ALB

  enable_deletion_protection = false

  # Target Group Configuration
  target_group_name     = "${var.aws_region}-${var.environment}-tg-01"
  target_group_port     = 80
  target_group_protocol = "HTTP"

  # Health Check Configuration
  health_check_path                = "/"
  health_check_interval           = 30
  health_check_timeout            = 5
  health_check_healthy_threshold  = 2
  health_check_unhealthy_threshold = 2
  health_check_matcher            = "200"

  # Listener Configuration (HTTP only as requested)
  listener_port     = 80
  listener_protocol = "HTTP"

  # No HTTPS configuration as per your request
  certificate_arn = null

  # Auto Scaling Group Configuration - aligned with your naming
  asg_name            = "${var.aws_region}-${var.environment}-asg-01"
  ami_id              = var.ami_id  # Use your existing AMI
  instance_type       = var.instance_type  # Use your existing instance type
  key_name            = var.key_name  # Use your existing key name
  user_data           = local.user_data  # Reference to the user_data local variable

  # ASG Sizing
  asg_min_size         = 2
  asg_max_size         = 4
  asg_desired_capacity = 2
  health_check_grace_period = 300

  # Security Configuration
  allow_ssh        = true
  ssh_cidr_blocks  = ["0.0.0.0/0"]  # Matches your current SG config

  # Auto Scaling Policies
  enable_auto_scaling_policies = true
  scale_up_cpu_threshold      = 70
  scale_down_cpu_threshold    = 30

  # Attach your existing EC2 instances to the target group
  existing_instance_ids = [
    module.Frontend_vm.instance_id,
    module.backend_vm.instance_id
  ]

  # Tags - aligned with your existing tags
  tags = var.tags
}

# Output definitions as before
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.application_load_balancer.alb_dns_name
}

output "flask_application_url" {
  description = "URL to access the Flask application through ALB"
  value       = module.application_load_balancer.application_url
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.application_load_balancer.target_group_arn
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.application_load_balancer.asg_name
}

output "Backend_vm_ip" {
  value = module.backend_vm.instance_public_ip
}

output "Frontend_vm_ip" {
  value = module.Frontend_vm.instance_public_ip
}
