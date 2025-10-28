# Environment
environment  = "f-api"
project_name = "synthefy-test"
aws_region   = "us-east-2"

# VPC Configuration
vpc_id = "vpc-01234567890123456"
private_subnet_ids = ["subnet-01234567890123456", "subnet-01234567890123456"]

# EC2 Auto Scaling Configuration
instance_type    = "g5.4xlarge"
min_capacity     = 1
max_capacity     = 10
desired_capacity = 1
root_volume_size = 100

# Container Configuration (from dev.tfvars)
container_name               = "synthefy-api"
container_image              = "637245294713.dkr.ecr.us-east-2.amazonaws.com/on-premises-forecasting-api:latest"
container_port               = 8000
container_memory             = 16384
container_memory_reservation = 15360
container_cpu                = 15360

container_environment = [
  {
    name  = "SYNTHEFY_USE_ACCESS_TOKEN"
    value = "0"
  },
  {
    name  = "USE_CELERY"
    value = "false"
  },
  {
    name  = "SYNTHEFY_ROUTER"
    value = "foundation_models"
  },
  {
    name  = "LICENSE_KEY"
    value = "YOUR_LICENSE_KEY"
  }
]

# ECS Service Configuration
desired_count          = 1
enable_execute_command = false

# Health Check Configuration
health_check_path                = "/"
health_check_matcher             = "200"
health_check_interval            = 30
health_check_timeout             = 5
health_check_healthy_threshold   = 2
health_check_unhealthy_threshold = 2

# Monitoring Configuration
enable_container_insights = true
log_retention_days        = 7

# Tags
tags = {
  Environment = "f-api"
  Project     = "synthefy-api-private"
  Component   = "test"
  ManagedBy   = "opentofu"
}
