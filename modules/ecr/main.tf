# =============================================================================
# ECR Module — Repositories for all application services
# =============================================================================

locals {
  ecr_prefix = var.ecr_prefix != "" ? var.ecr_prefix : var.project_name
}

resource "aws_ecr_repository" "repo" {
  for_each = var.repositories

  name                 = "${local.ecr_prefix}/${each.key}"
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name          = "${local.ecr_prefix}/${each.key}"
    ComputeTarget = each.value.compute_target
    Description   = each.value.description
  })
}

resource "aws_ecr_lifecycle_policy" "repo" {
  for_each = var.repositories

  repository = aws_ecr_repository.repo[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${each.value.max_image_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = each.value.max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
