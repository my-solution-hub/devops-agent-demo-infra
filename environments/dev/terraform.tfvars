# =============================================================================
# Development Environment — terraform.tfvars
# =============================================================================

project_name       = "aiops-demo"
availability_zones = ["us-east-1a", "us-east-1b"]

# VPC
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

# EKS — smaller footprint for dev
eks_cluster_version     = "1.29"
eks_node_instance_types = ["t3.medium"]
eks_node_desired_size   = 2
eks_node_min_size       = 1
eks_node_max_size       = 3

# EC2 — minimal instances
ec2_instance_type  = "t3.micro"
ec2_instance_count = 1

# ECS — lightweight tasks
ecs_container_image = "nginx:latest"
ecs_container_port  = 80
ecs_task_cpu        = 256
ecs_task_memory     = 512
ecs_desired_count   = 1

# Lambda
lambda_runtime     = "python3.12"
lambda_memory_size = 128
lambda_timeout     = 30

# Tags
tags = {
  Environment = "dev"
  Project     = "aiops-demo"
  ManagedBy   = "terraform"
}
