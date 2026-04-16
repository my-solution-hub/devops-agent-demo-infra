# Tasks: GitHub OIDC Bootstrap

## Task 1: Create project structure and Terraform configuration
- [x] 1.1 Create `init/github/tf/providers.tf` with Terraform version constraint (`>= 1.7.0`), AWS provider (`~> 5.0`), and local backend (no remote backend block) `[Requirement 6.1, 6.2, 6.3, 6.4]`
- [x] 1.2 Create `init/github/tf/variables.tf` with all input variables: `aws_region`, `project_name`, `github_org` (required, no default), `github_repo` (required, no default), `github_branch`, `state_bucket_name`, `state_lock_table_name`, and `tags` `[Requirement 7.1]`
- [x] 1.3 Create `init/github/tf/outputs.tf` with outputs: `oidc_provider_arn`, `deploy_role_arn`, `deploy_role_name`, `state_bucket_name`, `state_bucket_arn`, `state_lock_table_name`, `state_lock_table_arn` `[Requirement 7.2, 7.3, 7.4]`

## Task 2: Create GitHub Actions OIDC provider and IAM role
- [x] 2.1 Create `init/github/tf/main.tf` with `tls_certificate` data source for GitHub's OIDC discovery endpoint and `aws_iam_openid_connect_provider` resource with URL `https://token.actions.githubusercontent.com`, client ID `sts.amazonaws.com`, and thumbprint from the data source `[Requirement 1.1, 1.2, 1.3]`
- [x] 2.2 Add `aws_iam_role` resource to `init/github/tf/main.tf` with trust policy using `sts:AssumeRoleWithWebIdentity`, `StringEquals` condition for `aud` = `sts.amazonaws.com`, and `StringLike` condition for `sub` = `repo:{org}/{repo}:ref:refs/heads/{branch}` `[Requirement 2.1, 2.2, 2.3, 2.4]`

## Task 3: Create IAM policies for the deploy role
- [x] 3.1 Create `init/github/tf/iam_policies.tf` with Terraform state access policy: S3 actions (`GetObject`, `PutObject`, `DeleteObject`, `ListBucket`) scoped to the state bucket ARN, and DynamoDB actions (`GetItem`, `PutItem`, `DeleteItem`) scoped to the lock table ARN `[Requirement 3.1, 3.2]`
- [x] 3.2 Add infrastructure deploy policy to `init/github/tf/iam_policies.tf` with explicitly enumerated actions (no wildcards) for: EC2/VPC, EKS, ECS, Lambda, IAM, Elastic Load Balancing, and CloudWatch Logs `[Requirement 3.3, 3.4]`
- [x] 3.3 Add `aws_iam_role_policy_attachment` resources to attach both policies to the GitHub Actions role `[Requirement 3.5]`

## Task 4: Create Terraform state backend resources
- [x] 4.1 Create `init/github/tf/state_backend.tf` with `aws_s3_bucket` resource using `var.state_bucket_name`, `prevent_destroy` lifecycle rule, and Name tag `[Requirement 4.4, 4.5]`
- [x] 4.2 Add `aws_s3_bucket_versioning` resource with status `Enabled` `[Requirement 4.1]`
- [x] 4.3 Add `aws_s3_bucket_server_side_encryption_configuration` resource with `aws:kms` algorithm and bucket key enabled `[Requirement 4.2]`
- [x] 4.4 Add `aws_s3_bucket_public_access_block` resource with all four settings set to `true` `[Requirement 4.3]`
- [x] 4.5 Add `aws_dynamodb_table` resource with hash key `LockID` (type `S`), `PAY_PER_REQUEST` billing mode, and `prevent_destroy` lifecycle rule `[Requirement 5.1, 5.2, 5.3, 5.4]`

## Task 5: Create example tfvars and README
- [x] 5.1 Create `init/github/tf/terraform.tfvars.example` with example values for all variables, including `github_org` and `github_repo` placeholders `[Requirement 7.1]`
- [x] 5.2 Create `init/github/tf/README.md` documenting: purpose, prerequisites, deployment steps (init, plan, apply), how to store the role ARN as a GitHub secret, and the relationship to the main AIOps project `[Requirement 8.1, 8.2]`

## Task 6: Validate Terraform configuration
- [x] 6.1 Run `terraform fmt -check` in the `init/github/tf` directory to verify formatting `[Requirement 6.1]`
- [x] 6.2 Run `terraform init` and `terraform validate` in the `init/github/tf` directory to verify the configuration is syntactically valid `[Requirement 6.2, 6.3]`
