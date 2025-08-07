# Application Load Balancer
resource "aws_lb" "main" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = length(var.public_subnet_ids) >= 2 ? var.public_subnet_ids : concat(var.public_subnet_ids, var.private_subnet_ids)

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, {
    Name = var.alb_name
    Type = "Application Load Balancer"
  })
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name_prefix = "${var.alb_name}-alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # HTTP access from anywhere
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere (optional)
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.alb_name}-alb-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = var.target_group_name
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.target_group_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  tags = merge(var.tags, {
    Name = var.target_group_name
  })

  lifecycle {
    create_before_destroy = true
  }
}


# ALB Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  # Optional: Add SSL certificate if HTTPS
  dynamic "default_action" {
    for_each = var.certificate_arn != null ? [1] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.main.arn
    }
  }

  tags = var.tags
}

# Optional HTTPS Listener (if certificate is provided)
resource "aws_lb_listener" "https" {
  count = var.certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = var.tags
}

# Launch Template for Auto Scaling
resource "aws_launch_template" "main" {
  name_prefix   = "${var.asg_name}-template-"
  description   = "Launch template for ${var.asg_name}"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = module.iam.instance_profile.name  # Reference IAM instance profile from IAM module
  }
  vpc_security_group_ids = [aws_security_group.ec2.id]

  # Removed the user_data field as CodeDeploy will handle the app deployment
  # user_data = base64encode(var.user_data)  # Removed this line

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.asg_name}-instance"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.asg_name}-volume"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# Security Group for EC2 instances
resource "aws_security_group" "ec2" {
  name_prefix = "${var.asg_name}-ec2-"
  description = "Security group for EC2 instances in Auto Scaling Group"
  vpc_id      = var.vpc_id

  # Allow traffic from ALB
  ingress {
    description     = "HTTP from ALB"
    from_port       = var.target_group_port
    to_port         = var.target_group_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH access (optional)
  dynamic "ingress" {
    for_each = var.allow_ssh ? [1] : []
    content {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_cidr_blocks
    }
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.asg_name}-ec2-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = var.asg_name
  vpc_zone_identifier = var.public_subnet_ids  # Use private subnets
  target_group_arns   = [aws_lb_target_group.main.arn]  # Ensure it’s connected to the ALB target group
  health_check_type   = "ELB"
  health_check_grace_period = var.health_check_grace_period

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.asg_name}-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  count = var.enable_auto_scaling_policies ? 1 : 0

  name                   = "${var.asg_name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

resource "aws_autoscaling_policy" "scale_down" {
  count = var.enable_auto_scaling_policies ? 1 : 0

  name                   = "${var.asg_name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# CloudWatch Alarms for Auto Scaling
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = var.enable_auto_scaling_policies ? 1 : 0

  alarm_name          = "${var.asg_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.scale_up_cpu_threshold
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_up[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  count = var.enable_auto_scaling_policies ? 1 : 0

  alarm_name          = "${var.asg_name}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.scale_down_cpu_threshold
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_down[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}

# Optional: Target Group Attachment for existing EC2 instances
resource "aws_lb_target_group_attachment" "existing_instances" {
  count = length(var.existing_instance_ids)

  target_group_arn = aws_lb_target_group.main.arn
  target_id        = var.existing_instance_ids[count.index]
  port             = var.target_group_port
}
