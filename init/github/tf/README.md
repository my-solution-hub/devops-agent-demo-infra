# GitHub OIDC Bootstrap — Terraform

This Terraform project bootstraps the foundational AWS infrastructure required before the main AIOps CI/CD pipeline can operate. It is a **one-time, manual deployment** run from a developer's local machine.

## What It Creates

- **GitHub Actions OIDC Provider** — Registers GitHub's token endpoint (`token.actions.githubusercontent.com`) as an IAM identity provider so GitHub Actions can authenticate to AWS using short-lived OIDC tokens instead of long-lived credentials.
- **IAM Role** — An assumable role (`aiops-demo-github-actions-role`) with a trust policy scoped to a specific GitHub repository and branch.
- **IAM Policies** — Two policies attached to the role: one for Terraform state access (S3 + DynamoDB), and one for deploying the full AIOps infrastructure (VPC, EC2, EKS, ECS, Lambda, IAM, ALB, CloudWatch Logs).
- **S3 Bucket** — Stores the main project's Terraform remote state, with versioning, KMS encryption, and public access blocked.
- **DynamoDB Table** — Provides state locking to prevent concurrent Terraform operations.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.7.0
- AWS CLI configured with a profile named **`cloudops-demo`** that has permissions to create IAM, S3, and DynamoDB resources
- The `cloudops-demo` profile must target the **us-east-1** region (hardcoded in `providers.tf`)

## Configuration

1. Copy the example tfvars file:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and set the required values:

   | Variable | Required | Description |
   |---|---|---|
   | `github_org` | **Yes** | Your GitHub organization or username |
   | `github_repo` | **Yes** | Repository name (without the org prefix) |
   | `project_name` | No | Project name for resource naming (default: `aiops-demo`) |
   | `github_branch` | No | Branch allowed to assume the deploy role (default: `release`) |
   | `state_bucket_name` | No | S3 bucket name for Terraform state (default: `aiops-demo-terraform-state`) |
   | `state_lock_table_name` | No | DynamoDB table name for state locking (default: `aiops-demo-terraform-locks`) |
   | `tags` | No | Common tags applied to all resources |

> **Note:** There is no `aws_region` variable. The region is hardcoded to `us-east-1` in `providers.tf` using the `cloudops-demo` AWS CLI profile.

## Deployment

This project uses **local Terraform state** intentionally — it must be deployable before any remote backend exists.

### Step 1: Initialize

```bash
terraform init
```

### Step 2: Review the plan

```bash
terraform plan
```

### Step 3: Apply

```bash
terraform apply
```

### Step 4: Store the role ARN as a GitHub secret

After a successful apply, Terraform prints the outputs. Set the `deploy_role_arn` as a GitHub Actions secret using the `gh` CLI:

```bash
gh secret set AWS_DEPLOY_ROLE_ARN \
  --repo my-solution-hub/devops-agent-demo-infra \
  --body "$(terraform output -raw deploy_role_arn)"
```

Or manually via the GitHub UI:

1. Go to your repository on GitHub → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `AWS_DEPLOY_ROLE_ARN`
4. Value: the `deploy_role_arn` output

You can retrieve the outputs at any time:

```bash
terraform output deploy_role_arn
```

## Current Deployment

The bootstrap infrastructure has been deployed to AWS account `719821274597` (us-east-1):

| Resource | Value |
|---|---|
| OIDC Provider | `arn:aws:iam::719821274597:oidc-provider/token.actions.githubusercontent.com` |
| Deploy Role ARN | `arn:aws:iam::719821274597:role/aiops-demo-github-actions-role` |
| State Bucket | `aiops-demo-terraform-state-719821274597` |
| Lock Table | `aiops-demo-terraform-locks` |
| GitHub Secret | `AWS_DEPLOY_ROLE_ARN` set on `my-solution-hub/devops-agent-demo-infra` |

## Relationship to the Main AIOps Project

This bootstrap project is a **prerequisite** for the main AIOps infrastructure project. The main project's GitHub Actions workflow uses the IAM role created here to authenticate via OIDC, and its Terraform backend is configured to use the S3 bucket and DynamoDB table created here:

```hcl
# In the main project's backend configuration:
terraform {
  backend "s3" {
    bucket         = "aiops-demo-terraform-state-719821274597"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aiops-demo-terraform-locks"
    encrypt        = true
  }
}
```

## File Structure

```
init/github/tf/
├── providers.tf                 # Terraform + AWS provider (local state, cloudops-demo profile)
├── variables.tf                 # Input variables
├── main.tf                      # OIDC provider + IAM role
├── iam_policies.tf              # IAM policies for the deploy role
├── state_backend.tf             # S3 bucket + DynamoDB table
├── outputs.tf                   # Outputs (role ARN, bucket name, etc.)
├── terraform.tfvars.example     # Example variable values
└── README.md                    # This file
```

## Outputs

| Output | Description |
|---|---|
| `oidc_provider_arn` | ARN of the GitHub Actions OIDC provider |
| `deploy_role_arn` | ARN of the IAM role (use as `AWS_DEPLOY_ROLE_ARN` GitHub secret) |
| `deploy_role_name` | Name of the IAM role |
| `state_bucket_name` | S3 bucket name for Terraform remote state |
| `state_bucket_arn` | S3 bucket ARN for Terraform remote state |
| `state_lock_table_name` | DynamoDB table name for state locking |
| `state_lock_table_arn` | DynamoDB table ARN for state locking |
