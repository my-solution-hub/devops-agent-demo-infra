# =============================================================================
# Root Outputs — AIOps Infrastructure Deployment
# =============================================================================
# Actual output values will be wired when modules are added.

# -----------------------------------------------------------------------------
# VPC Outputs
# -----------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

# -----------------------------------------------------------------------------
# EKS Outputs
# -----------------------------------------------------------------------------
output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

# -----------------------------------------------------------------------------
# EC2 Outputs
# -----------------------------------------------------------------------------
output "ec2_instance_ids" {
  description = "List of EC2 instance IDs"
  value       = module.ec2.instance_ids
}

output "ec2_private_ips" {
  description = "List of EC2 private IP addresses"
  value       = module.ec2.private_ips
}

# -----------------------------------------------------------------------------
# ECS Outputs
# -----------------------------------------------------------------------------
output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = module.ecs.cluster_id
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "ecs_alb_dns_name" {
  description = "DNS name of the ECS Application Load Balancer"
  value       = module.ecs.alb_dns_name
}

# -----------------------------------------------------------------------------
# Lambda Outputs
# -----------------------------------------------------------------------------
output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.function_arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.function_name
}
