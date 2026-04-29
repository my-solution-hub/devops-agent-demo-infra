# =============================================================================
# AgentCore Module — Runtime, ECR, Security Group, IAM
# =============================================================================

# -----------------------------------------------------------------------------
# ECR Repository — stores the agent container image
# -----------------------------------------------------------------------------

resource "aws_ecr_repository" "agent" {
  name                 = "${var.project_name}-agentcore"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-agentcore-ecr"
  })
}

resource "aws_ecr_lifecycle_policy" "agent" {
  repository = aws_ecr_repository.agent.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Security Group — egress-only for VPC-attached runtime
# -----------------------------------------------------------------------------

resource "aws_security_group" "agentcore" {
  name        = "${var.project_name}-agentcore-sg"
  description = "Security group for AgentCore runtime"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-agentcore-sg"
  })
}

#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group_rule" "agentcore_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.agentcore.id
  description       = "Allow all outbound traffic"
}

# -----------------------------------------------------------------------------
# IAM Role — assumed by bedrock-agentcore service
# -----------------------------------------------------------------------------

resource "aws_iam_role" "agentcore" {
  name = "${var.project_name}-agentcore-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock-agentcore.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-agentcore-role"
  })
}

resource "aws_iam_role_policy" "agentcore_ecr" {
  name = "${var.project_name}-agentcore-ecr"
  role = aws_iam_role.agentcore.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = [aws_ecr_repository.agent.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "agentcore_bedrock" {
  role       = aws_iam_role.agentcore.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group
# -----------------------------------------------------------------------------

#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "agentcore" {
  name              = "/agentcore/${var.project_name}"
  retention_in_days = 14

  tags = merge(var.tags, {
    Name = "${var.project_name}-agentcore-logs"
  })
}

# -----------------------------------------------------------------------------
# Bedrock AgentCore Runtime
# -----------------------------------------------------------------------------

resource "aws_bedrockagentcore_agent_runtime" "main" {
  agent_runtime_name = var.agent_runtime_name
  description        = var.description
  role_arn           = aws_iam_role.agentcore.arn

  agent_runtime_artifact {
    container_configuration {
      container_uri = var.container_uri
    }
  }

  network_configuration {
    network_mode = "VPC"

    network_mode_config {
      security_groups = [aws_security_group.agentcore.id]
      subnets         = var.private_subnet_ids
    }
  }

  protocol_configuration {
    server_protocol = var.protocol
  }

  lifecycle_configurations {
    idle_runtime_session_timeout = var.idle_session_timeout
    max_lifetime                 = var.max_lifetime
  }

  environment_variables = var.environment_variables

  tags = merge(var.tags, {
    Name = "${var.project_name}-agentcore-runtime"
  })
}
