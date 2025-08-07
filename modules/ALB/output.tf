# modules/alb/outputs.tf

# ALB Outputs
output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

# Target Group Outputs
output "target_group_id" {
  description = "ID of the target group"
  value       = aws_lb_target_group.main.id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.main.name
}

# Listener Outputs
output "listener_arn" {
  description = "ARN of the ALB listener"
  value       = aws_lb_listener.main.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS ALB listener"
  value       = var.certificate_arn != null ? aws_lb_listener.https[0].arn : null
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

# Auto Scaling Group Outputs
output "asg_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.id
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

# Launch Template Outputs
output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.main.id
}

output "launch_template_arn" {
  description = "ARN of the launch template"
  value       = aws_launch_template.main.arn
}

# Auto Scaling Policy Outputs
output "scale_up_policy_arn" {
  description = "ARN of the scale up policy"
  value       = var.enable_auto_scaling_policies ? aws_autoscaling_policy.scale_up[0].arn : null
}

output "scale_down_policy_arn" {
  description = "ARN of the scale down policy"
  value       = var.enable_auto_scaling_policies ? aws_autoscaling_policy.scale_down[0].arn : null
}

# URL for accessing the application
output "application_url" {
  description = "URL to access the application through ALB"
  value       = "http://${aws_lb.main.dns_name}"
}

output "https_application_url" {
  description = "HTTPS URL to access the application through ALB"
  value       = var.certificate_arn != null ? "https://${aws_lb.main.dns_name}" : null
}
