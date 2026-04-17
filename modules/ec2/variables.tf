# =============================================================================
# EC2 Module — Input Variables
# =============================================================================

variable "project_name" {
  type        = string
  description = "Project name used for resource naming and tagging"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EC2 instances will be deployed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for EC2 placement"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 instances (distributed across AZs)"
  default     = 2
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instances"
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default     = {}
}
