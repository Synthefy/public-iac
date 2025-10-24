# Load Balancer Outputs
output "load_balancer_dns_name" {
  description = "DNS name of the private load balancer"
  value       = aws_lb.synthefy_api_private.dns_name
}

output "load_balancer_arn" {
  description = "ARN of the private load balancer"
  value       = aws_lb.synthefy_api_private.arn
}

output "load_balancer_zone_id" {
  description = "Zone ID of the private load balancer"
  value       = aws_lb.synthefy_api_private.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.synthefy_api_private.arn
}

# ECS Cluster Outputs
output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.synthefy_api_private.id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.synthefy_api_private.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.synthefy_api_private.name
}

# ECS Service Outputs
output "ecs_service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.synthefy_api_private.id
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.synthefy_api_private.name
}

# Auto Scaling Group Outputs
output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.synthefy_api_private.id
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.synthefy_api_private.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.synthefy_api_private.name
}

# Launch Template Outputs
output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.synthefy_api_private.id
}

output "launch_template_arn" {
  description = "ARN of the launch template"
  value       = aws_launch_template.synthefy_api_private.arn
}

# Capacity Provider Outputs
output "capacity_provider_id" {
  description = "ID of the capacity provider"
  value       = aws_ecs_capacity_provider.synthefy_api_private.id
}

output "capacity_provider_arn" {
  description = "ARN of the capacity provider"
  value       = aws_ecs_capacity_provider.synthefy_api_private.arn
}

output "capacity_provider_name" {
  description = "Name of the capacity provider"
  value       = aws_ecs_capacity_provider.synthefy_api_private.name
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ecs_instances_security_group_id" {
  description = "ID of the ECS instances security group"
  value       = aws_security_group.ecs_instances.id
}

output "ecs_tasks_security_group_id" {
  description = "ID of the ECS tasks security group"
  value       = aws_security_group.ecs_tasks.id
}

# CloudWatch Logs Outputs
output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.synthefy_api_private.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.synthefy_api_private.arn
}

# IAM Role Outputs
output "execution_role_arn" {
  description = "ARN of the ECS execution role"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "execution_role_name" {
  description = "Name of the ECS execution role"
  value       = aws_iam_role.ecs_execution_role.name
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "task_role_name" {
  description = "Name of the ECS task role"
  value       = aws_iam_role.ecs_task_role.name
}

output "instance_role_arn" {
  description = "ARN of the ECS instance role"
  value       = aws_iam_role.ecs_instance_role.arn
}

output "instance_role_name" {
  description = "Name of the ECS instance role"
  value       = aws_iam_role.ecs_instance_role.name
}

output "instance_profile_arn" {
  description = "ARN of the ECS instance profile"
  value       = aws_iam_instance_profile.ecs_instance_profile.arn
}

output "instance_profile_name" {
  description = "Name of the ECS instance profile"
  value       = aws_iam_instance_profile.ecs_instance_profile.name
}

# Task Definition Outputs
output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.synthefy_api_private.arn
}

output "task_definition_family" {
  description = "Family of the ECS task definition"
  value       = aws_ecs_task_definition.synthefy_api_private.family
}

output "task_definition_revision" {
  description = "Revision of the ECS task definition"
  value       = aws_ecs_task_definition.synthefy_api_private.revision
}



