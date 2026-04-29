# GitOps Workflow — AIOps Demo Infrastructure

This document describes how to work on this repository: the branching model, development workflow, CI/CD pipeline, environment promotion, and day-to-day operational procedures.

## Branching Model

This repo uses a **trunk-based development** model with a dedicated deployment branch:

| Branch | Purpose |
|---|---|
| `main` | Primary development branch. All feature work merges here. |
| `release` | Deployment branch. Merging to `release` triggers `terraform apply` against AWS. |
| `feature/*` | Short-lived branches for individual changes. Branch from `main`, merge back to `main`. |

```
feature/add-rds  ──○──○──○──┐
                             ▼
main             ──○──○──○──○──○──○──┐
                                      ▼
release          ──○──────────────────○──→  terraform apply
```

Only the `release` branch deploys infrastructure. Every other branch runs validation and security scans only.

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout main
git pull origin main
git checkout -b feature/your-change-description
```

### 2. Make Changes Locally

Edit Terraform files as needed. Common change types:

- **New module** — add a directory under `modules/`, wire it into `main.tf`
- **Variable change** — update `variables.tf` and the relevant `environments/*.tfvars` files
- **Environment tuning** — edit `environments/dev/terraform.tfvars` or `environments/prod/terraform.tfvars`

### 3. Validate Locally Before Pushing

```bash
# Format check
terraform fmt -check -recursive

# Initialize (no backend needed for validation)
terraform init -backend=false

# Validate syntax and configuration
terraform validate
```

Optionally, run a plan against the dev environment if you have AWS credentials configured locally:

```bash
terraform plan -var-file=environments/dev/terraform.tfvars
```

### 4. Push and Open a Pull Request

```bash
git push -u origin feature/your-change-description
```

Open a pull request targeting `main`. The CI pipeline will automatically run validation and security scans on your PR (see [CI/CD Pipeline](#cicd-pipeline) below).

### 5. Code Review and Merge to Main

- Get at least one approval from a team member.
- Ensure all CI checks pass (format, validate, tfsec, Checkov).
- Squash-merge or merge into `main`.

### 6. Promote to Release (Deploy)

When `main` is ready to deploy:

```bash
git checkout release
git pull origin release
git merge main
git push origin release
```

This triggers the full deploy pipeline: validate → security scan → plan → apply.

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/terraform.yml`) runs on every push and pull request.

### Pipeline Stages

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│   Validate & Lint   │────▶│   Security Scan      │────▶│   Deploy            │
│                     │     │                      │     │  (release only)     │
│ • terraform fmt     │     │ • tfsec (hard fail)  │     │ • OIDC auth to AWS  │
│ • terraform init    │     │ • Checkov (soft fail)│     │ • terraform init    │
│ • terraform validate│     │   (skips init/)      │     │ • terraform plan    │
└─────────────────────┘     └─────────────────────┘     │ • terraform apply   │
     All branches              All branches              └─────────────────────┘
                                                           release branch only
```

| Stage | Runs On | Fails Build? |
|---|---|---|
| `terraform fmt -check` | All branches | Yes |
| `terraform init -backend=false` | All branches | Yes |
| `terraform validate` | All branches | Yes |
| tfsec | All branches | Yes (hard fail) |
| Checkov | All branches | No (soft fail) |
| `terraform plan` | `release` only | Yes |
| `terraform apply` | `release` only | Yes |

### AWS Authentication

The deploy job uses **GitHub OIDC** to assume an IAM role in AWS — no long-lived credentials are stored in GitHub. The role ARN is stored as the `AWS_DEPLOY_ROLE_ARN` repository secret. The OIDC trust policy restricts role assumption to the `release` branch only.

### GitHub Environment Protection

The deploy job targets the `production` GitHub environment. You can configure environment protection rules in GitHub (Settings → Environments → production):

- Required reviewers for manual approval before deploy
- Wait timers
- Branch restrictions (already scoped to `release` in the workflow)

## Environment Management

Infrastructure sizing is controlled through environment-specific variable files:

```
environments/
├── dev/terraform.tfvars      # Smaller instances, fewer replicas
└── prod/terraform.tfvars     # Larger instances, more replicas
```

### Key Differences Between Environments

| Parameter | Dev | Prod |
|---|---|---|
| EKS node type | `t3.medium` | `t3.large` |
| EKS desired nodes | 2 | 3 |
| EC2 instance type | `t3.micro` | `t3.small` |
| EC2 count | 1 | 3 |
| ECS task CPU/memory | 256 / 512 | 512 / 1024 |
| ECS desired count | 1 | 3 |
| Lambda memory | 128 MB | 256 MB |

### Switching Environments

The current pipeline deploys using the default variable values (which align with dev). To target a specific environment in a local plan:

```bash
terraform plan -var-file=environments/dev/terraform.tfvars
terraform plan -var-file=environments/prod/terraform.tfvars
```

> **Note:** The CI/CD pipeline currently runs `terraform plan` and `apply` without a `-var-file` flag, so it uses the defaults defined in `variables.tf`. To deploy a specific environment via CI, update the workflow or add a workflow input to select the tfvars file.

## Terraform State

State is stored remotely in S3 with DynamoDB locking:

| Resource | Value |
|---|---|
| S3 bucket | `aiops-demo-terraform-state-719821274597` |
| State key | `infrastructure/terraform.tfstate` |
| Region | `us-east-1` |
| DynamoDB table | `aiops-demo-terraform-locks` |
| Encryption | Enabled (SSE) |

State locking prevents concurrent `terraform apply` operations. If a lock gets stuck (e.g., a CI run was killed mid-apply), you can force-unlock it:

```bash
terraform force-unlock <LOCK_ID>
```

Use this with caution — only when you are certain no other operation is running.

## Bootstrap / First-Time Setup

Before the CI/CD pipeline can operate, the OIDC provider, IAM role, S3 backend, and DynamoDB table must exist. These are created by a one-time bootstrap project:

```
init/github/tf/
```

See [init/github/tf/README.md](../init/github/tf/README.md) for full instructions. In summary:

1. Configure the `cloudops-demo` AWS CLI profile.
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and set your GitHub org/repo.
3. Run `terraform init && terraform apply` from `init/github/tf/`.
4. Copy the output role ARN into the GitHub repository secret `AWS_DEPLOY_ROLE_ARN`.

This bootstrap uses local state intentionally — it must run before the remote backend exists.

## Project Structure Quick Reference

```
├── main.tf                     # Root module — wires VPC, EKS, EC2, ECS, Lambda, AgentCore
├── variables.tf                # All root input variables with validation rules
├── outputs.tf                  # Root outputs from all modules
├── providers.tf                # AWS provider config, version constraints, S3 backend
├── environments/
│   ├── dev/terraform.tfvars    # Dev sizing and tags
│   └── prod/terraform.tfvars   # Prod sizing and tags
├── modules/
│   ├── agentcore/              # Bedrock AgentCore runtime, ECR, IAM, security group
│   ├── ec2/                    # EC2 instances, security group, IAM instance profile
│   ├── ecs/                    # ECS Fargate cluster, ALB, task definition, service
│   └── lambda/                 # Lambda function, IAM role, CloudWatch logs
├── docs/
│   ├── architecture.md         # Architecture docs and diagrams
│   └── gitops.md               # This document
├── init/github/tf/             # One-time OIDC bootstrap (local state)
└── .github/workflows/
    └── terraform.yml           # CI/CD pipeline
```

Community modules (sourced from the Terraform registry):
- `terraform-aws-modules/vpc/aws ~> 5.0`
- `terraform-aws-modules/eks/aws ~> 20.0`

## Common Operations

### Adding a New Module

1. Create a directory under `modules/` with `main.tf`, `variables.tf`, and `outputs.tf`.
2. Wire the module into the root `main.tf`.
3. Add any new variables to the root `variables.tf`.
4. Add environment-specific values to both `environments/dev/terraform.tfvars` and `environments/prod/terraform.tfvars`.
5. Export relevant outputs in the root `outputs.tf`.

### Changing Resource Sizing

Edit the appropriate `environments/<env>/terraform.tfvars` file. No module code changes needed — sizing is driven entirely by variables.

### Updating Provider or Module Versions

1. Edit the version constraint in `providers.tf` (for the AWS provider) or `main.tf` (for community modules).
2. Run `terraform init -upgrade` to update the lock file.
3. Commit the updated `.terraform.lock.hcl`.

### Handling a Failed Deploy

If `terraform apply` fails mid-run on the `release` branch:

1. Check the GitHub Actions log for the error.
2. Fix the issue in a feature branch, merge to `main`, then merge to `release` again.
3. If state is locked, use `terraform force-unlock <LOCK_ID>` after confirming no other operation is running.
4. If state is corrupted, restore from the S3 bucket's version history.

### Destroying Infrastructure

This is a high-risk operation. Run locally with explicit confirmation:

```bash
terraform destroy -var-file=environments/dev/terraform.tfvars
```

Never add `-auto-approve` to destroy commands without team consensus.

## Security Practices

- **No long-lived AWS credentials.** CI/CD uses GitHub OIDC with short-lived tokens.
- **OIDC trust is branch-scoped.** Only the `release` branch can assume the deploy role.
- **Security scanning on every push.** tfsec runs as a hard gate; Checkov runs as a soft check.
- **All compute in private subnets.** Only the ALB sits in public subnets.
- **IMDSv2 enforced** on EC2 instances (hop limit = 1).
- **State encryption** enabled on the S3 backend.
- **State locking** via DynamoDB prevents concurrent modifications.
- **ECR image scanning** enabled on push for the AgentCore container registry.
