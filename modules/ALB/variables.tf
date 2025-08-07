# modules/alb/variables.tf

# ALB Configuration
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}
variable "instance_profile" {
  description = "Name of the instance_profile"
  type        = string
}
variable "vpc_id" {
  description = "VPC ID where ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Auto Scaling Group"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

# Target Group Configuration
variable "target_group_name" {
  description = "Name of the target group"
  type        = string
}

variable "target_group_port" {
  description = "Port for target group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol for target group"
  type        = string
  default     = "HTTP"
}

# Health Check Configuration
variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Health check interval"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Health check healthy threshold"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Health check unhealthy threshold"
  type        = number
  default     = 2
}

variable "health_check_matcher" {
  description = "Health check matcher"
  type        = string
  default     = "200"
}

# Listener Configuration
variable "listener_port" {
  description = "Port for ALB listener"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocol for ALB listener"
  type        = string
  default     = "HTTP"
}

# SSL Configuration (Optional)
variable "certificate_arn" {
  description = "SSL certificate ARN for HTTPS listener"
  type        = string
  default     = null
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

# Auto Scaling Group Configuration
variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for launch template"
  type        = string
}

variable "instance_type" {
  description = "Instance type for launch template"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script for EC2 instances"
  type        = string
  default     = ""
}

variable "asg_min_size" {
  description = "Minimum size of Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum size of Auto Scaling Group"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired capacity of Auto Scaling Group"
  type        = number
  default     = 2
}

variable "health_check_grace_period" {
  description = "Health check grace period for Auto Scaling Group"
  type        = number
  default     = 300
}

# Security Group Configuration
variable "allow_ssh" {
  description = "Allow SSH access to EC2 instances"
  type        = bool
  default     = true
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Auto Scaling Policies
variable "enable_auto_scaling_policies" {
  description = "Enable auto scaling policies based on CPU"
  type        = bool
  default     = true
}

variable "scale_up_cpu_threshold" {
  description = "CPU threshold for scaling up"
  type        = number
  default     = 70
}

variable "scale_down_cpu_threshold" {
  description = "CPU threshold for scaling down"
  type        = number
  default     = 30
}

# Existing EC2 Instances (Optional)
variable "existing_instance_ids" {
  description = "List of existing EC2 instance IDs to attach to target group"
  type        = list(string)
  default     = []
}

# Common Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
