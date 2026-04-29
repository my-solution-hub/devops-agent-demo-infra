# AIOps Demo Infrastructure

Terraform project that provisions a multi-service AWS infrastructure for an AIOps demo application. The stack deploys EKS, EC2, ECS Fargate, Lambda, and Bedrock AgentCore workloads inside a shared VPC distributed across two Availability Zones.

## Architecture Summary

All compute resources run in private subnets behind a shared NAT gateway. An Application Load Balancer in public subnets fronts the ECS Fargate service. The EKS cluster runs managed node groups across both AZs. EC2 instances are distributed using modular index assignment. A VPC-attached Lambda function handles event-driven workloads. A Bedrock AgentCore Runtime hosts AI agents using container-based deployment.

A GitHub Actions pipeline validates every push and deploys to AWS from the `release` branch using OIDC authentication — no long-lived credentials.

See [docs/architecture.md](docs/architecture.md) for the full architecture documentation and diagrams.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.7.0
- AWS account with the OIDC bootstrap already deployed (see [init/github/tf/README.md](init/github/tf/README.md))
- GitHub repository with the `AWS_DEPLOY_ROLE_ARN` secret set from the bootstrap output
- AWS CLI (optional, for local plan/apply)

## Quick Start

The S3 backend is **configured per environment** via `-backend-config`, so dev and prod
write to separate state keys (`infrastructure/dev/…` vs `infrastructure/prod/…`) and
cannot overwrite each other.

```bash
# Dev
terraform init -backend-config=environments/dev/backend.hcl
terraform plan  -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

```bash
# Prod — run from a clean .terraform/ or use -reconfigure
terraform init -reconfigure -backend-config=environments/prod/backend.hcl
terraform plan  -var-file=environments/prod/terraform.tfvars
terraform apply -var-file=environments/prod/terraform.tfvars
```

CI selects the environment via the `TF_ENV` variable in
`.github/workflows/terraform.yml` (defaults to `dev`).

## Project Structure

```
├── main.tf                          # Root module — wires all child modules
├── variables.tf                     # Root input variables
├── outputs.tf                       # Root outputs from all modules
├── providers.tf                     # Provider config, version constraints, S3 backend
├── environments/
│   ├── dev/
│   │   ├── backend.hcl              # Dev S3 backend config (state key)
│   │   └── terraform.tfvars         # Dev environment values
│   └── prod/
│       ├── backend.hcl              # Prod S3 backend config (state key)
│       └── terraform.tfvars         # Prod environment values
├── modules/
│   ├── agentcore/                   # AgentCore runtime, ECR, IAM, security group
│   ├── ec2/                         # EC2 instances, security group, IAM profile
│   ├── ecr/                         # ECR repositories for all application services
│   ├── ecs/                         # ECS Fargate cluster, ALB, task definition
│   └── lambda/                      # Lambda function, IAM role, CloudWatch logs
├── docs/
│   └── architecture.md              # Architecture docs and diagrams
├── init/
│   └── github/tf/                   # GitHub OIDC bootstrap (one-time setup)
├── .github/
│   └── workflows/terraform.yml      # CI/CD pipeline
└── .kiro/
    ├── steering/infra-docs.md       # Auto-documentation steering file
    └── hooks/                       # Kiro hooks for automation
```

The VPC and EKS modules use open-source community modules (`terraform-aws-modules/vpc/aws ~> 5.0` and `terraform-aws-modules/eks/aws ~> 20.0`). EC2, ECS, ECR, Lambda, and AgentCore use custom modules under `modules/`.

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/terraform.yml`) runs on every push:

| Stage | All Branches | Release Branch |
|---|---|---|
| `terraform fmt -check` | Yes | Yes |
| `terraform init` | Yes (no backend) | Yes (with backend) |
| `terraform validate` | Yes | Yes |
| `terraform plan` | — | Yes |
| `terraform apply` | — | Yes |

Deployment to AWS only happens on the `release` branch. AWS credentials are obtained via GitHub OIDC — the workflow assumes the IAM role created by the bootstrap project.

## Bootstrap Setup

Before the CI/CD pipeline can deploy, you need to run the one-time OIDC bootstrap:

1. `cd init/github/tf`
2. `cp terraform.tfvars.example terraform.tfvars` and fill in your GitHub org/repo
3. `terraform init && terraform apply`
4. Set the output role ARN as a GitHub secret: `AWS_DEPLOY_ROLE_ARN`

Full instructions: [init/github/tf/README.md](init/github/tf/README.md)

## Configuration

Environment-specific values live in `environments/{env}/terraform.tfvars`. Key settings:

| Variable | Default | Description |
|---|---|---|
| `project_name` | `aiops-demo` | Prefix for all resource names |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `availability_zones` | `us-east-1a, us-east-1b` | AZs for resource distribution |
| `eks_cluster_version` | `1.29` | Kubernetes version |
| `eks_node_instance_types` | `t3.medium` | EKS node instance types |
| `ec2_instance_type` | `t3.micro` | EC2 instance type |
| `ec2_instance_count` | `2` | Number of EC2 instances |
| `ecs_container_image` | `nginx:latest` | ECS task container image |
| `lambda_runtime` | `python3.12` | Lambda runtime |
| `agentcore_runtime_name` | `aiops_demo_agent` | AgentCore runtime name |
| `agentcore_protocol` | `HTTP` | AgentCore protocol (HTTP, MCP, A2A) |

See `variables.tf` for the full list with descriptions and validation rules.
