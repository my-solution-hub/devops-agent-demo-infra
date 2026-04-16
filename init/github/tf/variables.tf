variable "project_name" {
  type        = string
  description = "Project name used for resource naming"
  default     = "aiops-demo"
}

variable "github_org" {
  type        = string
  description = "GitHub organization or username"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name (without org prefix)"
}

variable "github_branch" {
  type        = string
  description = "Branch allowed to assume the deploy role"
  default     = "release"
}

variable "state_bucket_name" {
  type        = string
  description = "S3 bucket name for the main project's Terraform state"
  default     = "aiops-demo-terraform-state"
}

variable "state_lock_table_name" {
  type        = string
  description = "DynamoDB table name for the main project's state locking"
  default     = "aiops-demo-terraform-locks"
}

variable "tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default = {
    Project   = "aiops-demo"
    ManagedBy = "terraform"
    Component = "oidc-bootstrap"
  }
}
