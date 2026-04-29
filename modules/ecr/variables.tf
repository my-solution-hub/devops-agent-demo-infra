# =============================================================================
# ECR Module — Input Variables
# =============================================================================

variable "project_name" {
  type        = string
  description = "Project name used for resource naming and tagging"
}

variable "ecr_prefix" {
  type        = string
  description = "Prefix for ECR repository names (e.g. cat-demo). Defaults to project_name if not set."
  default     = ""
}

variable "repositories" {
  type = map(object({
    description          = string
    compute_target       = string
    image_tag_mutability = optional(string, "MUTABLE")
    max_image_count      = optional(number, 10)
  }))
  description = "Map of ECR repositories to create. Key is the repo suffix (e.g. api-gateway), value contains metadata."
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default     = {}
}
