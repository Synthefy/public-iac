# IAM role for ECS task execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "synthefy-api-private-ecs-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-ecs-execution-role-${var.environment}"
    Environment = var.environment
  })
}

# Attach the ECS task execution role policy
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for ECS Exec permissions
resource "aws_iam_role_policy" "ecs_execution_exec_policy" {
  name = "ecs-exec-execution-policy-${var.environment}"
  role = aws_iam_role.ecs_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:DescribeSessions",
          "ssm:TerminateSession",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:PutParameter",
          "ssm:DeleteParameter",
          "ssm:DescribeParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM role for ECS tasks
resource "aws_iam_role" "ecs_task_role" {
  name = "synthefy-api-private-ecs-task-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-ecs-task-role-${var.environment}"
    Environment = var.environment
  })
}

# Custom policy for ECS Exec permissions on task role
resource "aws_iam_role_policy" "ecs_task_exec_policy" {
  name = "ecs-exec-task-policy-${var.environment}"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:DescribeSessions",
          "ssm:TerminateSession",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:PutParameter",
          "ssm:DeleteParameter",
          "ssm:DescribeParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM role for ECS instances
resource "aws_iam_role" "ecs_instance_role" {
  name = "synthefy-api-private-ecs-instance-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-ecs-instance-role-${var.environment}"
    Environment = var.environment
  })
}

# Attach the ECS instance role policy
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Attach SSM managed instance policy to ECS instance role
resource "aws_iam_role_policy_attachment" "ecs_instance_role_ssm_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM instance profile for ECS instances
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "synthefy-api-private-ecs-instance-profile-${var.environment}"
  role = aws_iam_role.ecs_instance_role.name

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-ecs-instance-profile-${var.environment}"
    Environment = var.environment
  })
}



