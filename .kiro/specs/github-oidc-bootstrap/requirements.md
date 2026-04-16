# Requirements: GitHub OIDC Bootstrap

## Requirement 1: GitHub Actions OIDC Identity Provider

### Description
Create an AWS IAM OIDC identity provider for GitHub Actions so that GitHub Actions workflows can authenticate to AWS using short-lived tokens instead of long-lived credentials.

### Acceptance Criteria
- 1.1 Given the bootstrap project is applied, when the OIDC provider is created, then its URL is exactly `https://token.actions.githubusercontent.com`.
- 1.2 Given the OIDC provider is created, when its configuration is inspected, then the client ID list contains exactly `sts.amazonaws.com`.
- 1.3 Given the OIDC provider is created, when its thumbprint is inspected, then it is derived from the `tls_certificate` data source pointing to GitHub's OIDC discovery endpoint.

---

## Requirement 2: IAM Role with OIDC Trust Policy

### Description
Create an IAM role that GitHub Actions can assume via OIDC web identity federation, with the trust policy scoped to a specific GitHub repository and branch to prevent unauthorized access.

### Acceptance Criteria
- 2.1 Given the IAM role is created, when its trust policy is inspected, then the allowed action is `sts:AssumeRoleWithWebIdentity` (not `sts:AssumeRole`).
- 2.2 Given the IAM role trust policy, when the `sub` condition is inspected, then it uses `StringLike` matching the pattern `repo:{github_org}/{github_repo}:ref:refs/heads/{github_branch}`.
- 2.3 Given the IAM role trust policy, when the `aud` condition is inspected, then it uses `StringEquals` with value `sts.amazonaws.com`.
- 2.4 Given the IAM role is created, when its name is inspected, then it follows the pattern `{project_name}-github-actions-role`.

---

## Requirement 3: IAM Policies for Infrastructure Deployment

### Description
Attach IAM policies to the GitHub Actions role that grant sufficient permissions for the main AIOps project to deploy its full infrastructure (VPC, EC2, EKS, ECS, Lambda, IAM roles, ALB, CloudWatch), plus access to the Terraform state backend.

### Acceptance Criteria
- 3.1 Given the Terraform state access policy, when its statements are inspected, then S3 actions (`GetObject`, `PutObject`, `DeleteObject`, `ListBucket`) are scoped to the specific state bucket ARN.
- 3.2 Given the Terraform state access policy, when its statements are inspected, then DynamoDB actions (`GetItem`, `PutItem`, `DeleteItem`) are scoped to the specific lock table ARN.
- 3.3 Given the infrastructure deploy policy, when its statements are inspected, then it includes permissions for all required AWS services: EC2/VPC, EKS, ECS, Lambda, IAM, Elastic Load Balancing, and CloudWatch Logs.
- 3.4 Given any IAM policy created by this project, when its action lists are inspected, then no statement uses a wildcard action (`"*"`); all actions are explicitly enumerated.
- 3.5 Given both policies are created, when the role's attached policies are inspected, then both the state access policy and the infrastructure deploy policy are attached to the GitHub Actions role.

---

## Requirement 4: S3 Bucket for Terraform Remote State

### Description
Create an S3 bucket that the main AIOps project will use as its Terraform remote state backend, with versioning, encryption, and public access protections enabled.

### Acceptance Criteria
- 4.1 Given the S3 bucket is created, when its versioning configuration is inspected, then versioning status is `Enabled`.
- 4.2 Given the S3 bucket is created, when its encryption configuration is inspected, then server-side encryption is enabled using `aws:kms` algorithm with bucket key enabled.
- 4.3 Given the S3 bucket is created, when its public access block is inspected, then all four settings are `true`: `block_public_acls`, `block_public_policy`, `ignore_public_acls`, `restrict_public_buckets`.
- 4.4 Given the S3 bucket resource definition, when its lifecycle configuration is inspected, then `prevent_destroy` is set to `true`.
- 4.5 Given the S3 bucket is created, when its name is inspected, then it matches the `state_bucket_name` variable (default: `aiops-demo-terraform-state`).

---

## Requirement 5: DynamoDB Table for State Locking

### Description
Create a DynamoDB table that the main AIOps project will use for Terraform state locking to prevent concurrent modifications.

### Acceptance Criteria
- 5.1 Given the DynamoDB table is created, when its schema is inspected, then the hash key is `LockID` with type `S` (String).
- 5.2 Given the DynamoDB table is created, when its billing mode is inspected, then it is set to `PAY_PER_REQUEST`.
- 5.3 Given the DynamoDB table resource definition, when its lifecycle configuration is inspected, then `prevent_destroy` is set to `true`.
- 5.4 Given the DynamoDB table is created, when its name is inspected, then it matches the `state_lock_table_name` variable (default: `aiops-demo-terraform-locks`).

---

## Requirement 6: Terraform Configuration and Local State

### Description
Configure the bootstrap project to use local Terraform state (since it must be deployable before any remote backend exists), with proper version constraints and provider pinning.

### Acceptance Criteria
- 6.1 Given the Terraform configuration, when the backend is inspected, then no remote backend is configured (local state is used).
- 6.2 Given the Terraform configuration, when version constraints are checked, then the required Terraform version is `>= 1.7.0`.
- 6.3 Given the Terraform configuration, when the AWS provider is inspected, then its version is pinned to `~> 5.0`.
- 6.4 Given the provider configuration, when default tags are inspected, then they are set from the `var.tags` variable.

---

## Requirement 7: Variables and Outputs

### Description
Expose configurable variables for all environment-specific values and provide outputs that downstream projects and GitHub secrets need.

### Acceptance Criteria
- 7.1 Given the project variables, when `github_org` and `github_repo` are inspected, then they are required variables with no defaults (must be explicitly provided).
- 7.2 Given the project outputs, when `deploy_role_arn` is inspected, then it exposes the IAM role ARN suitable for use as the `AWS_DEPLOY_ROLE_ARN` GitHub secret.
- 7.3 Given the project outputs, when `state_bucket_name` and `state_lock_table_name` are inspected, then they expose the names matching what the main project's backend configuration expects.
- 7.4 Given the project outputs, when `oidc_provider_arn` is inspected, then it exposes the OIDC provider ARN for reference.

---

## Requirement 8: Resource Tagging

### Description
Apply consistent tags to all resources for operational visibility and cost tracking, following the same conventions as the main AIOps project.

### Acceptance Criteria
- 8.1 Given any resource created by this project, when its tags are inspected, then it has at minimum `Project`, `ManagedBy`, and `Component` tags.
- 8.2 Given any named resource, when its `Name` tag is inspected, then it follows the pattern `{project_name}-{resource_descriptor}`.
