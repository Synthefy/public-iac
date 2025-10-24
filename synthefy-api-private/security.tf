# Security group for ECS instances
resource "aws_security_group" "ecs_instances" {
  name        = "synthefy-api-private-ecs-instances-${var.environment}"
  description = "Security group for ECS instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "Container port from ALB"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-ecs-instances-${var.environment}"
    Environment = var.environment
  })
}

# Security group for Application Load Balancer
resource "aws_security_group" "alb" {
  name        = "synthefy-api-private-alb-${var.environment}"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-alb-${var.environment}"
    Environment = var.environment
  })
}

# Security group for ECS tasks (awsvpc networking mode)
resource "aws_security_group" "ecs_tasks" {
  name        = "synthefy-api-private-ecs-tasks-${var.environment}"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description = "Container port from ALB"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-ecs-tasks-${var.environment}"
    Environment = var.environment
  })
}
