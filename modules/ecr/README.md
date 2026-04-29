# ECR Module

Creates ECR repositories for all application container images. Each repository gets image scanning on push, AES256 encryption, and a lifecycle policy to limit stored image count.

## Usage

```hcl
module "ecr" {
  source = "./modules/ecr"

  project_name = "aiops-demo"
  repositories = {
    api-gateway = {
      description    = "API Gateway service"
      compute_target = "ecs"
    }
    worker = {
      description      = "Background worker"
      compute_target   = "eks"
      max_image_count  = 20
    }
  }
  tags = { Environment = "dev" }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_name` | `string` | — | Project name used for resource naming and tagging |
| `ecr_prefix` | `string` | `""` | Prefix for ECR repository names (e.g. `cat-demo`). Defaults to `project_name` if not set. |
| `repositories` | `map(object)` | — | Map of ECR repositories to create. Key is the repo suffix, value contains metadata. |
| `repositories[].description` | `string` | — | Human-readable description of the repository |
| `repositories[].compute_target` | `string` | — | Target compute service (e.g. `eks`, `ecs`, `lambda`) |
| `repositories[].image_tag_mutability` | `string` | `"MUTABLE"` | Tag mutability setting (`MUTABLE` or `IMMUTABLE`) |
| `repositories[].max_image_count` | `number` | `10` | Max images to retain via lifecycle policy |
| `tags` | `map(string)` | `{}` | Common tags applied to all resources |

## Outputs

| Name | Description |
|------|-------------|
| `repository_urls` | Map of repository name suffix to ECR repository URL |
| `repository_arns` | Map of repository name suffix to ECR repository ARN |

## Resources Created

- `aws_ecr_repository` — One per entry in `var.repositories`
- `aws_ecr_lifecycle_policy` — One per repository (expires images beyond `max_image_count`)
