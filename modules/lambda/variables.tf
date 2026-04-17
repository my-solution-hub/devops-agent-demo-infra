# =============================================================================
# Lambda Module — Input Variables
# =============================================================================

variable "project_name" {
  type        = string
  description = "Project name used for resource naming and tagging"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the Lambda function will be deployed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for VPC-attached Lambda"
}

variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "runtime" {
  type        = string
  description = "Lambda runtime"
  default     = "python3.12"
}

variable "handler" {
  type        = string
  description = "Lambda handler"
  default     = "main.handler"
}

variable "memory_size" {
  type        = number
  description = "Memory allocation in MB"
  default     = 128
}

variable "timeout" {
  type        = number
  description = "Function timeout in seconds"
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default     = {}
}
