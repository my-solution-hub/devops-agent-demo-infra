# =============================================================================
# ECS Module — Input Variables
# =============================================================================

variable "project_name" {
  type        = string
  description = "Project name used for resource naming and tagging"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where ECS resources will be deployed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for ECS tasks"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for the ALB"
}

variable "container_image" {
  type        = string
  description = "Docker image for the ECS task"
  default     = "nginx:latest"
}

variable "container_port" {
  type        = number
  description = "Port the container listens on"
  default     = 80
}

variable "task_cpu" {
  type        = number
  description = "CPU units for the Fargate task"
  default     = 256
}

variable "task_memory" {
  type        = number
  description = "Memory (MiB) for the Fargate task"
  default     = 512
}

variable "desired_count" {
  type        = number
  description = "Desired number of ECS tasks"
  default     = 2
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default     = {}
}
