# Public Infrastructure as Code

This repository serves as a storehouse for Infrastructure as Code (IaC) modules and configurations for Synthefy's cloud infrastructure.

## Available Modules

### On-Premises Forecasting API
A Terraform module that deploys the On-Premises Forecasting API containers behind a private AWS Application Load Balancer on ECS using GPU instances.

**Key Features:**
- Private load balancer accessible only within VPC
- GPU instance support (g5.4xlarge)
- Auto-scaling with ECS capacity providers
- Secure cross-account ECR access

📖 **[View Documentation →](./synthefy-api-private/README.md)**

## Getting Started

Each module contains its own documentation and deployment instructions. Navigate to the specific module directory for detailed setup and configuration guidance.

## Support

For questions about these infrastructure modules, contact the Synthefy team at contact@synthefy.com.
