# Synthefy API Private Module

This Terraform module deploys the On-Premises Forecasting API containers behind a private AWS Application Load Balancer on ECS using EC2 instances with Auto Scaling Groups. The module is designed to use GPU instances (g5.4xlarge) and provides a scalable, secure infrastructure for containerized applications.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Synthefy API Private Module              │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │ Private ALB     │              │ ECS Cluster     │      │
│  │                 │              │                 │      │
│  │ ┌─────────────┐ │              │ ┌─────────────┐ │      │
│  │ │ Target      │ │──────────────│ │ Forecasting │ │      │
│  │ │ Group       │ │              │ │ API         │ │      │
│  │ │             │ │              │ │             │ │      │
│  │ └─────────────┘ │              │ └─────────────┘ │      │
│  └─────────────────┘              └─────────────────┘      │
│                                                             │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │ Auto Scaling    │              │ Security        │      │
│  │ Group           │              │ Groups          │      │
│  │                 │              │                 │      │
│  │ ┌─────────────┐ │              │ ┌─────────────┐ │      │
│  │ │ g5.4xlarge  │ │              │ │ ALB SG      │ │      │
│  │ │ GPU         │ │              │ │ ECS SG      │ │      │
│  │ │ Instances   │ │              │ │ Tasks SG    │ │      │
│  │ │             │ │              │ │             │ │      │
│  │ └─────────────┘ │              │ └─────────────┘ │      │
│  └─────────────────┘              └─────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Features

- **Private Load Balancer**: Internal ALB accessible only within VPC
- **GPU Instance Support**: Uses g5.4xlarge instances with GPU capabilities
- **Auto Scaling**: ECS capacity provider with managed scaling
- **Security**: Proper security group rules for ALB-to-container communication
- **Monitoring**: CloudWatch Container Insights and logging
- **IAM**: Minimal permissions for execution, tasks, and EC2 instances
- **Health Checks**: Configurable health check parameters

## Prerequisites

Before deploying this module, ensure the following are already deployed:

1. **VPC Infrastructure**: A VPC with private subnets where the load balancer and ECS tasks will be deployed
2. **Remote State**: S3 bucket and DynamoDB table for Terraform state management
3. **AWS Credentials**: Proper AWS credentials configured
4. **ECR Repository Access**: The On-Premises Forecasting API image is hosted in Synthefy's private ECR repository `857077105278.dkr.ecr.us-east-2.amazonaws.com/on-premises-forecasting-api`. Your AWS account must be whitelisted in our repository policy to access this image.

## VPC Configuration

This module requires you to provide VPC information directly as input variables:

- `vpc_id`: The ID of your existing VPC
- `vpc_cidr_block`: The CIDR block of your VPC (e.g., "10.0.0.0/16")
- `private_subnet_ids`: List of private subnet IDs where the load balancer and ECS tasks will be deployed

**Example:**
```hcl
vpc_id = "vpc-12345678"
vpc_cidr_block = "10.0.0.0/16"
private_subnet_ids = ["subnet-11111111", "subnet-22222222"]
```

## Usage

### Basic Deployment

```bash
# Navigate to the module directory
cd modules/synthefy-api-private

# Update dev.tfvars with your VPC information
# Provide vpc_id, vpc_cidr_block, and private_subnet_ids

# Initialize Terraform
terraform init -backend-config=backend-dev.conf

# Review the plan
terraform plan -var-file=terraform.tfvars

# Apply the configuration
terraform apply -var-file=terraform.tfvars
```

### Custom Configuration

Create a custom `.tfvars` file based on the provided `example.tfvars`:

```hcl
# custom.tfvars
environment = "production"
aws_region = "us-west-2"
project_name = "synthefy-api-private"

# VPC Configuration - Replace with your VPC information
vpc_id = "vpc-your-vpc-id"
vpc_cidr_block = "10.1.0.0/16"
private_subnet_ids = ["subnet-your-subnet-1", "subnet-your-subnet-2"]

# EC2 Configuration
instance_type = "g5.8xlarge"
min_capacity = 2
max_capacity = 20
desired_capacity = 3

# Container Configuration
container_image = "857077105278.dkr.ecr.us-east-2.amazonaws.com/on-premises-forecasting-api:latest"
container_memory = 8192
container_cpu = 4096

tags = {
  Environment = "production"
  Project     = "synthefy-api-private"
  CostCenter  = "production"
}
```

Then deploy with:

```bash
terraform apply -var-file=custom.tfvars
```

## ECR Image Management

This module uses Synthefy's private ECR repository for the On-Premises Forecasting API. The default image is:

```
857077105278.dkr.ecr.us-east-2.amazonaws.com/on-premises-forecasting-api:latest
```

### Repository Access Requirements

**Important**: This ECR repository belongs to Synthefy and requires whitelisting for access. Before deploying this module, ensure that:

1. **Your AWS Account is Whitelisted**: Your AWS account ID must be added to Synthefy's ECR repository policy
2. **Cross-Account Access**: The ECS execution role in your account needs permission to pull images from Synthefy's ECR repository
3. **Contact Synthefy**: If you don't have access, contact the Synthefy team (contact@synthefy.com) to whitelist your AWS account ID.

### Getting Access

To request access to the ECR repository:

1. **Provide your AWS Account ID** to the Synthefy team
2. **Specify the region** where you'll be deploying (us-east-2)
3. **Indicate the repository name**: `on-premises-forecasting-api`
4. **Wait for confirmation** that your account has been whitelisted

### Using Different Image Tags

To use a specific version or tag of the image, update the `container_image` variable:

```hcl
# Use a specific version
container_image = "857077105278.dkr.ecr.us-east-2.amazonaws.com/on-premises-forecasting-api:v1.2.3"

# Use a development build
container_image = "857077105278.dkr.ecr.us-east-2.amazonaws.com/on-premises-forecasting-api:dev-2024-01-15"
```

### ECR Authentication

**Note**: You can only authenticate if your AWS account has been whitelisted in Synthefy's ECR repository policy.

The ECS execution role automatically has permissions to pull from the ECR repository once your account is whitelisted. If you need to manually authenticate with ECR:

```bash
# Login to ECR (requires whitelisted account)
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 857077105278.dkr.ecr.us-east-2.amazonaws.com

# Pull the image locally (for testing)
docker pull 857077105278.dkr.ecr.us-east-2.amazonaws.com/on-premises-forecasting-api:latest
```

**Troubleshooting Authentication**:
- If you get "access denied" errors, your AWS account may not be whitelisted
- Contact the Synthefy team to verify your account has been added to the repository policy
- Ensure you're using the correct AWS credentials for the whitelisted account

## Input Variables

### Infrastructure Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| aws_region | AWS region | `string` | `"us-east-2"` | no |
| project_name | Project name | `string` | `"synthefy-api-private"` | no |

### VPC Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | VPC ID where resources will be created | `string` | n/a | yes |
| vpc_cidr_block | CIDR block of the VPC | `string` | n/a | yes |
| private_subnet_ids | List of private subnet IDs for the load balancer and ECS service | `list(string)` | n/a | yes |

### EC2 and Auto Scaling

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance_type | EC2 instance type (must be GPU instance) | `string` | `"g5.4xlarge"` | no |
| min_capacity | Minimum number of instances in ASG | `number` | `1` | no |
| max_capacity | Maximum number of instances in ASG | `number` | `10` | no |
| desired_capacity | Desired number of instances in ASG | `number` | `1` | no |
| root_volume_size | Size of root EBS volume in GB | `number` | `100` | no |

### Container Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| container_name | Name of the container | `string` | `"synthefy-api"` | no |
| container_image | Docker image for the container | `string` | `"857077105278.dkr.ecr.us-east-2.amazonaws.com/on-premises-forecasting-api:latest"` | no |
| container_port | Port on which container listens | `number` | `80` | no |
| container_memory | Memory allocation in MB | `number` | `2048` | no |
| container_memory_reservation | Memory reservation in MB | `number` | `1536` | no |
| container_cpu | CPU allocation in CPU units | `number` | `1024` | no |
| container_environment | Environment variables for container | `list(object)` | `[]` | no |

### ECS Service

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| desired_count | Desired number of tasks in ECS service | `number` | `1` | no |
| enable_execute_command | Enable ECS Exec for debugging | `bool` | `false` | no |

### Health Checks

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| health_check_path | Health check path | `string` | `"/"` | no |
| health_check_matcher | Health check response codes | `string` | `"200"` | no |
| health_check_interval | Health check interval in seconds | `number` | `30` | no |
| health_check_timeout | Health check timeout in seconds | `number` | `5` | no |
| health_check_healthy_threshold | Consecutive successes required | `number` | `2` | no |
| health_check_unhealthy_threshold | Consecutive failures required | `number` | `2` | no |

### Monitoring

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_container_insights | Enable CloudWatch Container Insights | `bool` | `true` | no |
| log_retention_days | CloudWatch log retention in days | `number` | `7` | no |

### Tags

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

### Load Balancer

| Name | Description |
|------|-------------|
| load_balancer_dns_name | DNS name of the private load balancer |
| load_balancer_arn | ARN of the private load balancer |
| load_balancer_zone_id | Zone ID of the private load balancer |
| target_group_arn | ARN of the target group |

### ECS

| Name | Description |
|------|-------------|
| ecs_cluster_id | ID of the ECS cluster |
| ecs_cluster_arn | ARN of the ECS cluster |
| ecs_cluster_name | Name of the ECS cluster |
| ecs_service_id | ID of the ECS service |
| ecs_service_name | Name of the ECS service |

### Auto Scaling

| Name | Description |
|------|-------------|
| autoscaling_group_id | ID of the Auto Scaling Group |
| autoscaling_group_arn | ARN of the Auto Scaling Group |
| autoscaling_group_name | Name of the Auto Scaling Group |
| launch_template_id | ID of the launch template |
| capacity_provider_id | ID of the capacity provider |

### Security Groups

| Name | Description |
|------|-------------|
| alb_security_group_id | ID of the ALB security group |
| ecs_instances_security_group_id | ID of the ECS instances security group |
| ecs_tasks_security_group_id | ID of the ECS tasks security group |

### IAM

| Name | Description |
|------|-------------|
| execution_role_arn | ARN of the ECS execution role |
| task_role_arn | ARN of the ECS task role |
| instance_role_arn | ARN of the ECS instance role |
| instance_profile_arn | ARN of the ECS instance profile |

### Monitoring

| Name | Description |
|------|-------------|
| log_group_name | Name of the CloudWatch log group |
| log_group_arn | ARN of the CloudWatch log group |

## Accessing the Private Load Balancer

Since this module creates a **private** load balancer, it's only accessible from within the VPC. To access it:

1. **From EC2 instances in the same VPC**:
   ```bash
   curl http://<load_balancer_dns_name>/
   ```

2. **From a bastion host or VPN connection**:
   - Ensure your bastion host is in the same VPC
   - Use the load balancer DNS name from the outputs

3. **For testing purposes**, you can temporarily create a public subnet instance:
   ```bash
   # Get the load balancer DNS name
   terraform output load_balancer_dns_name
   
   # Test from an instance in the same VPC
   curl http://$(terraform output -raw load_balancer_dns_name)/
   ```

## Scaling Configuration

### Manual Scaling

Update the desired capacity:

```bash
# Scale up to 3 instances
terraform apply -var="desired_capacity=3" -var-file=dev.tfvars

# Scale down to 1 instance
terraform apply -var="desired_capacity=1" -var-file=dev.tfvars
```

### Auto Scaling

The module includes managed scaling through ECS capacity providers:

- **Target Capacity**: 100% (configurable)
- **Minimum Scaling Step**: 1 instance
- **Maximum Scaling Step**: 10 instances
- **Scaling is based on**: ECS service desired count and available capacity

## GPU Instance Considerations

### Supported Instance Types

This module is designed for GPU instances. Supported types include:

- `g5.4xlarge` (default) - 4 vCPUs, 16 GB RAM, 1 GPU
- `g5.8xlarge` - 8 vCPUs, 32 GB RAM, 1 GPU
- `g5.12xlarge` - 12 vCPUs, 48 GB RAM, 4 GPUs
- `g5.16xlarge` - 16 vCPUs, 64 GB RAM, 1 GPU
- `g5.24xlarge` - 24 vCPUs, 96 GB RAM, 4 GPUs

### Cost Considerations

GPU instances are significantly more expensive than standard instances:

- **g5.4xlarge**: ~$1.21/hour (us-east-2)
- **g5.8xlarge**: ~$2.45/hour (us-east-2)
- **g5.12xlarge**: ~$3.67/hour (us-east-2)

**Recommendations**:
- Use smaller instance types for development
- Implement proper auto-scaling to scale down during low usage
- Consider using Spot instances for non-production workloads
- Monitor costs with AWS Cost Explorer

## Troubleshooting

### Common Issues

1. **VPC Remote State Not Found**
   ```
   Error: Failed to get existing workspaces: NoSuchBucket
   ```
   **Solution**: Ensure the VPC module is deployed first and the remote state bucket exists.

2. **Insufficient Capacity**
   ```
   Error: InsufficientInstanceCapacity
   ```
   **Solution**: Try a different availability zone or instance type.

3. **Health Check Failures**
   ```
   Error: Target group health checks failing
   ```
   **Solution**: Verify the On-Premises Forecasting API container is listening on the correct port and the health check path is accessible.

4. **ECR Image Pull Failures**
   ```
   Error: CannotPullContainerError: Error response from daemon: pull access denied
   ```
   **Solution**: Your AWS account must be whitelisted in Synthefy's ECR repository policy. Contact the Synthefy team to request access.

5. **Image Not Found**
   ```
   Error: Repository does not exist
   ```
   **Solution**: Verify the ECR repository exists and the image tag is correct. If you can't access the repository, ensure your account is whitelisted.

6. **Cross-Account Access Denied**
   ```
   Error: User is not authorized to perform: ecr:GetAuthorizationToken
   ```
   **Solution**: This indicates your AWS account is not whitelisted in Synthefy's ECR repository. Contact Synthefy support to request access.

### Debugging Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster synthefy-api-private-dev --services synthefy-api-private-dev

# Check Auto Scaling Group status
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names synthefy-api-private-dev

# Check load balancer target health
aws elbv2 describe-target-health --target-group-arn <target_group_arn>

# View CloudWatch logs
aws logs describe-log-streams --log-group-name /ecs/synthefy-api-private-dev

# Check ECR repository and images (requires whitelisted account)
aws ecr describe-repositories --repository-names on-premises-forecasting-api --region us-east-2

# List available image tags (requires whitelisted account)
aws ecr list-images --repository-name on-premises-forecasting-api --region us-east-2

# Test ECR authentication
aws ecr get-login-password --region us-east-2
```

### ECS Exec Access

If `enable_execute_command` is set to `true`, you can access running containers:

```bash
# Get the task ARN
aws ecs list-tasks --cluster synthefy-api-private-dev --service-name synthefy-api-private-dev

# Execute command in container
aws ecs execute-command \
  --cluster synthefy-api-private-dev \
  --task <task-arn> \
  --container synthefy-api \
  --interactive \
  --command "/bin/bash"
```

## Security Considerations

1. **Private Load Balancer**: Only accessible within VPC
2. **Security Groups**: Restrictive rules for ALB and ECS communication
3. **IAM Roles**: Minimal permissions following least privilege principle
4. **Encrypted Storage**: EBS volumes are encrypted
5. **Network Isolation**: All resources deployed in private subnets

## Monitoring and Logging

### CloudWatch Container Insights

When enabled, provides detailed metrics for:
- CPU and memory utilization
- Network I/O
- Storage I/O
- Task and service metrics

### CloudWatch Logs

Container logs are automatically sent to CloudWatch with:
- Configurable retention period
- Structured logging
- Log aggregation by service

### Custom Metrics

You can add custom metrics by:
1. Installing CloudWatch agent on instances
2. Using AWS SDK in your application
3. Configuring custom log-based metrics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This module is part of the Synthefy infrastructure and follows the same licensing terms.
