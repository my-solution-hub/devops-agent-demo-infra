# =============================================================================
# AgentCore Module — Outputs
# =============================================================================

output "agent_runtime_arn" {
  description = "ARN of the AgentCore runtime"
  value       = aws_bedrockagentcore_agent_runtime.main.agent_runtime_arn
}

output "agent_runtime_id" {
  description = "Unique identifier of the AgentCore runtime"
  value       = aws_bedrockagentcore_agent_runtime.main.agent_runtime_id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for the agent container image"
  value       = aws_ecr_repository.agent.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.agent.arn
}

output "security_group_id" {
  description = "Security group ID for the AgentCore runtime"
  value       = aws_security_group.agentcore.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role used by the AgentCore runtime"
  value       = aws_iam_role.agentcore.arn
}
