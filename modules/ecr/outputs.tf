# =============================================================================
# ECR Module — Outputs
# =============================================================================

output "repository_urls" {
  description = "Map of repository name suffix to ECR repository URL"
  value       = { for k, v in aws_ecr_repository.repo : k => v.repository_url }
}

output "repository_arns" {
  description = "Map of repository name suffix to ECR repository ARN"
  value       = { for k, v in aws_ecr_repository.repo : k => v.arn }
}
