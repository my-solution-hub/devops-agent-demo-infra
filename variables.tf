# =============================================================================
# Root Variables — AIOps Infrastructure Deployment
# =============================================================================

# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------

variable "project_name" {
  type        = string
  description = "Project name used for resource naming and tagging"
  default     = "aiops-demo"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default = {
    Project   = "aiops-demo"
    ManagedBy = "terraform"
  }
}

# -----------------------------------------------------------------------------
# VPC / Networking
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block (e.g. 10.0.0.0/16)."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "List of Availability Zones to distribute resources across"
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 Availability Zones are required for high availability."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (one per AZ)"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All public_subnet_cidrs must be valid CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets (one per AZ)"
  default     = ["10.0.10.0/24", "10.0.20.0/24"]

  validation {
    condition     = alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All private_subnet_cidrs must be valid CIDR blocks."
  }
}

# -----------------------------------------------------------------------------
# EKS
# -----------------------------------------------------------------------------

variable "eks_cluster_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster"
  default     = "1.29"
}

variable "eks_node_instance_types" {
  type        = list(string)
  description = "EC2 instance types for EKS managed node group"
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  type        = number
  description = "Desired number of nodes in the EKS node group"
  default     = 2

  validation {
    condition     = var.eks_node_desired_size >= 1
    error_message = "eks_node_desired_size must be at least 1."
  }
}

variable "eks_node_min_size" {
  type        = number
  description = "Minimum number of nodes in the EKS node group"
  default     = 1

  validation {
    condition     = var.eks_node_min_size >= 1
    error_message = "eks_node_min_size must be at least 1."
  }
}

variable "eks_node_max_size" {
  type        = number
  description = "Maximum number of nodes in the EKS node group"
  default     = 4

  validation {
    condition     = var.eks_node_max_size >= 1
    error_message = "eks_node_max_size must be at least 1."
  }
}

# -----------------------------------------------------------------------------
# EC2
# -----------------------------------------------------------------------------

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type for compute instances"
  default     = "t3.micro"
}

variable "ec2_instance_count" {
  type        = number
  description = "Number of EC2 instances to provision (distributed across AZs)"
  default     = 2

  validation {
    condition     = var.ec2_instance_count >= 1
    error_message = "ec2_instance_count must be at least 1."
  }
}

# -----------------------------------------------------------------------------
# ECS
# -----------------------------------------------------------------------------

variable "ecs_container_image" {
  type        = string
  description = "Docker image for the ECS Fargate task"
  default     = "nginx:latest"
}

variable "ecs_container_port" {
  type        = number
  description = "Port the container listens on"
  default     = 80
}

variable "ecs_task_cpu" {
  type        = number
  description = "CPU units for the Fargate task (256, 512, 1024, 2048, 4096)"
  default     = 256
}

variable "ecs_task_memory" {
  type        = number
  description = "Memory (MiB) for the Fargate task"
  default     = 512
}

variable "ecs_desired_count" {
  type        = number
  description = "Desired number of ECS tasks"
  default     = 2

  validation {
    condition     = var.ecs_desired_count >= 1
    error_message = "ecs_desired_count must be at least 1."
  }
}

# -----------------------------------------------------------------------------
# Lambda
# -----------------------------------------------------------------------------

variable "lambda_runtime" {
  type        = string
  description = "Lambda function runtime"
  default     = "python3.12"
}

variable "lambda_memory_size" {
  type        = number
  description = "Memory allocation (MB) for the Lambda function"
  default     = 128

  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "lambda_memory_size must be between 128 and 10240 MB."
  }
}

variable "lambda_timeout" {
  type        = number
  description = "Lambda function timeout in seconds"
  default     = 30

  validation {
    condition     = var.lambda_timeout >= 1 && var.lambda_timeout <= 900
    error_message = "lambda_timeout must be between 1 and 900 seconds."
  }
}
