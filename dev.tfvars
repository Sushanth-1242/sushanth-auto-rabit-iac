aws_region         = "us-east-1"
environment        = "dev"
vpc_cidr_block     = "10.0.0.0/16"
subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
azs                = ["us-east-1b", "us-east-1c"]

tags = {
  "Environment" = "Dev"
  "Owner"       = "Sushanth"
}

route_table_tags = {
  "Environment" = "Dev"
  "Owner"       = "Sushanth"
}

subnet_tags = {
  Environment = "dev"
  Project     = "MyApp"
}

ami_id        = "ami-084a7d336e816906b"
instance_type = "t3.micro"
key_name      = "auto-rebit-poc"

# ALB Configuration - Replace dynamic references with static values
alb_name                             = "us-east-1-dev-alb-01"
alb_target_group_name                = "us-east-1-dev-tg-01"
alb_listener_port                    = 80
alb_health_check_path                = "/"
alb_health_check_interval            = 30
alb_health_check_timeout             = 5
alb_health_check_healthy_threshold   = 2
alb_health_check_unhealthy_threshold = 2
alb_health_check_matcher             = "200"

# Auto Scaling Group Configuration for ALB
asg_name                      = "us-east-1-dev-asg-01"
asg_min_size                  = 2
asg_max_size                  = 4
asg_desired_capacity          = 2
asg_health_check_grace_period = 300
scale_up_cpu_threshold        = 70
scale_down_cpu_threshold      = 30

# SSH and Security Group Configuration for ALB
allow_ssh       = true
ssh_cidr_blocks = ["0.0.0.0/0"] # Adjust based on your security group rules
existing_instance_ids = [
  module.Frontend_vm.instance_id,
  module.backend_vm.instance_id
]
