# =============================================================================
# VPC — terraform-aws-modules/vpc/aws
# =============================================================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}

# =============================================================================
# EKS — terraform-aws-modules/eks/aws
# =============================================================================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-eks"
  cluster_version = var.eks_cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  cluster_enabled_log_types = ["audit", "api", "authenticator"]

  eks_managed_node_groups = {
    default = {
      instance_types = var.eks_node_instance_types
      min_size       = var.eks_node_min_size
      max_size       = var.eks_node_max_size
      desired_size   = var.eks_node_desired_size
    }
  }

  tags = var.tags
}

# =============================================================================
# Amazon Linux 2023 AMI Data Source (for EC2)
# =============================================================================

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# =============================================================================
# EC2 — Custom Module
# =============================================================================

module "ec2" {
  source = "./modules/ec2"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  instance_type      = var.ec2_instance_type
  instance_count     = var.ec2_instance_count
  ami_id             = data.aws_ami.amazon_linux.id
  tags               = var.tags
}

# =============================================================================
# ECS Fargate — Custom Module
# =============================================================================

module "ecs" {
  source = "./modules/ecs"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets
  container_image    = var.ecs_container_image
  container_port     = var.ecs_container_port
  task_cpu           = var.ecs_task_cpu
  task_memory        = var.ecs_task_memory
  desired_count      = var.ecs_desired_count
  tags               = var.tags
}

# =============================================================================
# Lambda — Custom Module
# =============================================================================

module "lambda" {
  source = "./modules/lambda"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  function_name      = "${var.project_name}-handler"
  runtime            = var.lambda_runtime
  memory_size        = var.lambda_memory_size
  timeout            = var.lambda_timeout
  tags               = var.tags
}
