# Custom IAM policy for ECS task SSM access
resource "aws_iam_policy" "ecs_task_ssm_policy" {
  name        = "synthefy-api-private-ecs-task-ssm-policy-${var.environment}"
  description = "Policy for ECS tasks to access SSM for ECS Exec"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "synthefy-api-private-ecs-task-ssm-policy-${var.environment}"
    Environment = var.environment
  })
}

# Attach the custom SSM policy to the ECS task role
resource "aws_iam_role_policy_attachment" "ecs_task_ssm_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_ssm_policy.arn
}



