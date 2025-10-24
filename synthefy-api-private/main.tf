terraform {
  backend "s3" {}
}

# Data source to fetch the latest x86_64 GPU AMI
data "aws_ssm_parameter" "ecs_x86_gpu_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/gpu/recommended/image_id"
}

# ECS Cluster
resource "aws_ecs_cluster" "synthefy_api_private" {
  name = "synthefy-api-private-${var.environment}"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-${var.environment}"
    Environment = var.environment
  })
}

# Launch Template for ECS instances
resource "aws_launch_template" "synthefy_api_private" {
  name_prefix   = "synthefy-api-private-${var.environment}-"
  image_id      = data.aws_ssm_parameter.ecs_x86_gpu_ami.value
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ecs_instances.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = aws_ecs_cluster.synthefy_api_private.name
  }))

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name             = "synthefy-api-private-${var.environment}"
      Environment      = var.environment
      AmazonECSManaged = ""
    })
  }

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-${var.environment}"
    Environment = var.environment
  })
}

# Auto Scaling Group
resource "aws_autoscaling_group" "synthefy_api_private" {
  name                = "synthefy-api-private-${var.environment}"
  vpc_zone_identifier = var.private_subnet_ids
  protect_from_scale_in = false
  health_check_type   = "EC2"
  health_check_grace_period = 300

  min_size         = var.min_capacity
  max_size         = var.max_capacity
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.synthefy_api_private.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "synthefy-api-private-${var.environment}"
    propagate_at_launch = true
  }

  tag {
     key                 = "AmazonECSManaged"
     value               = "" # The value can be empty, it just needs to exist
     propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

# ECS Capacity Provider
resource "aws_ecs_capacity_provider" "synthefy_api_private" {
  name = "synthefy-api-private-${var.environment}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.synthefy_api_private.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 10
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-${var.environment}"
    Environment = var.environment
  })
}

# Attach capacity provider to cluster
resource "aws_ecs_cluster_capacity_providers" "synthefy_api_private" {
  cluster_name = aws_ecs_cluster.synthefy_api_private.name

  capacity_providers = [aws_ecs_capacity_provider.synthefy_api_private.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.synthefy_api_private.name
  }
}

# Application Load Balancer
resource "aws_lb" "synthefy_api_private" {
  name               = "synthefy-api-private-${var.environment}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.private_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-${var.environment}"
    Environment = var.environment
  })
}

# Target Group
resource "aws_lb_target_group" "synthefy_api_private" {
  name_prefix     = "syn"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-${var.environment}"
    Environment = var.environment
  })
}

# Load Balancer Listener
resource "aws_lb_listener" "synthefy_api_private" {
  load_balancer_arn = aws_lb.synthefy_api_private.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.synthefy_api_private.arn
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "synthefy_api_private" {
  family                   = "synthefy-api-private-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.container_image
      
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.synthefy_api_private.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      environment = var.container_environment

      memory = var.container_memory
      cpu    = var.container_cpu
      memoryReservation = var.container_memory_reservation

      resourceRequirements = [
        {
          type  = "GPU"
          value = "1"
        }
      ]
    }
  ])


  tags = merge(var.tags, {
    Name        = "synthefy-api-private-${var.environment}"
    Environment = var.environment
  })
}

# ECS Service
resource "aws_ecs_service" "synthefy_api_private" {
  name            = "synthefy-api-private-${var.environment}"
  cluster         = aws_ecs_cluster.synthefy_api_private.id
  task_definition = aws_ecs_task_definition.synthefy_api_private.arn
  desired_count   = var.desired_count
  enable_execute_command = var.enable_execute_command

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100


  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.synthefy_api_private.name
    weight            = 100
    base              = 1
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.synthefy_api_private.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  depends_on = [aws_lb_listener.synthefy_api_private]

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-${var.environment}"
    Environment = var.environment
  })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "synthefy_api_private" {
  name              = "/ecs/synthefy-api-private-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-${var.environment}"
    Environment = var.environment
  })
}
