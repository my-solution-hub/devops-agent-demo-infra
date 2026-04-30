# =============================================================================
# Production Environment — terraform.tfvars
# =============================================================================

project_name       = "aiops-demo"
availability_zones = ["us-east-1a", "us-east-1b"]

# VPC
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

# EKS — production-grade sizing
eks_cluster_version     = "1.32"
eks_node_instance_types = ["t3.large"]
eks_node_desired_size   = 3
eks_node_min_size       = 2
eks_node_max_size       = 6

# EC2 — larger instances, more capacity
ec2_instance_type  = "t3.small"
ec2_instance_count = 3

# ECS — higher capacity tasks
ecs_container_image = "nginx:latest"
ecs_container_port  = 80
ecs_task_cpu        = 512
ecs_task_memory     = 1024
ecs_desired_count   = 3

# Lambda — more memory for production workloads
lambda_runtime     = "python3.12"
lambda_memory_size = 256
lambda_timeout     = 60

# Tags
tags = {
  Environment = "prod"
  Project     = "aiops-demo"
  ManagedBy   = "terraform"
}
