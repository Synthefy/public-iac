# Infrastructure Variables
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "synthefy-api-private"
}

# VPC Configuration
variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the load balancer and ECS service"
  type        = list(string)
  validation {
    condition = length(var.private_subnet_ids) > 0
    error_message = "private_subnet_ids must be provided and non-empty."
  }
}

# EC2 and Auto Scaling
variable "instance_type" {
  description = "EC2 instance type for ECS cluster (must be GPU instance with at least 4GB memory and 8GB vCPU)"
  type        = string
  default     = "g5.4xlarge"
}

variable "min_capacity" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 10
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 100
}

# Container Configuration
variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "synthefy-api"
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 80
}

variable "container_memory" {
  description = "Memory allocation for the container (in MB)"
  type        = number
  default     = 2048
}

variable "container_memory_reservation" {
  description = "Memory reservation for the container (in MB)"
  type        = number
  default     = 1536
}

variable "container_cpu" {
  description = "CPU allocation for the container (in CPU units)"
  type        = number
  default     = 1024
}

variable "container_environment" {
  description = "Environment variables for the container"
  type        = list(object({
    name  = string
    value = string
  }))
  default = []
}

# ECS Service
variable "desired_count" {
  description = "Desired number of tasks running in the ECS service"
  type        = number
  default     = 1
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for the service"
  type        = bool
  default     = false
}

# Health Checks
variable "health_check_path" {
  description = "Health check path for the load balancer"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "Health check response codes"
  type        = string
  default     = "200"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health check successes required"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required"
  type        = number
  default     = 2
}

# Monitoring
variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the ECS cluster"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

# Tags
variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
