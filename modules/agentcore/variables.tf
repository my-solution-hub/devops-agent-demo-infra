# =============================================================================
# AgentCore Module — Input Variables
# =============================================================================

variable "project_name" {
  type        = string
  description = "Project name used for resource naming and tagging"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the AgentCore runtime will be deployed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for VPC-mode AgentCore runtime"
}

variable "container_uri" {
  type        = string
  description = "ECR URI of the agent container image (e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-agent:latest)"
}

variable "agent_runtime_name" {
  type        = string
  description = "Name of the AgentCore runtime (alphanumeric and underscores, max 48 chars)"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,47}$", var.agent_runtime_name))
    error_message = "agent_runtime_name must start with a letter, contain only alphanumeric characters and underscores, and be at most 48 characters."
  }
}

variable "description" {
  type        = string
  description = "Description of the AgentCore runtime"
  default     = ""
}

variable "protocol" {
  type        = string
  description = "Protocol the agent runtime uses to communicate (MCP, HTTP, A2A)"
  default     = "HTTP"

  validation {
    condition     = contains(["MCP", "HTTP", "A2A"], var.protocol)
    error_message = "protocol must be one of: MCP, HTTP, A2A."
  }
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables to set in the AgentCore runtime"
  default     = {}
}

variable "idle_session_timeout" {
  type        = number
  description = "Timeout in seconds for idle runtime sessions (60–28800)"
  default     = 900

  validation {
    condition     = var.idle_session_timeout >= 60 && var.idle_session_timeout <= 28800
    error_message = "idle_session_timeout must be between 60 and 28800 seconds."
  }
}

variable "max_lifetime" {
  type        = number
  description = "Maximum lifetime in seconds for runtime instances (60–28800)"
  default     = 28800

  validation {
    condition     = var.max_lifetime >= 60 && var.max_lifetime <= 28800
    error_message = "max_lifetime must be between 60 and 28800 seconds."
  }
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default     = {}
}
