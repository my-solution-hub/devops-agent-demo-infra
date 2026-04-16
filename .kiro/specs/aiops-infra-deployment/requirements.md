# Requirements: AIOps Infrastructure Deployment

## Requirement 1: VPC and Networking Foundation

### Description
Provision a shared VPC with public and private subnets distributed across multiple Availability Zones, including internet gateway, NAT gateways, and properly configured route tables.

### Acceptance Criteria
- 1.1 Given a valid VPC CIDR block and project name, when the VPC module is applied, then a VPC is created with DNS support and DNS hostnames enabled.
- 1.2 Given a list of at least 2 Availability Zones, when the VPC module is applied, then exactly one public subnet and one private subnet are created in each AZ.
- 1.3 Given public and private subnet CIDR blocks, when the VPC module is applied, then all subnet CIDRs fall within the VPC CIDR range and no two subnets have overlapping CIDRs.
- 1.4 Given the VPC is created, when the VPC module is applied, then an internet gateway is attached to the VPC.
- 1.5 Given the number of Availability Zones, when the VPC module is applied, then one NAT gateway is provisioned per AZ in the corresponding public subnet.
- 1.6 Given the VPC networking is complete, when route tables are configured, then public subnets route 0.0.0.0/0 through the internet gateway and private subnets route 0.0.0.0/0 through their AZ's NAT gateway.

---

## Requirement 2: EKS Cluster Deployment

### Description
Provision an EKS cluster with managed node groups distributed across Availability Zones within the shared VPC's private subnets.

### Acceptance Criteria
- 2.1 Given a Kubernetes version and VPC configuration, when the EKS module is applied, then an EKS cluster is created with the specified Kubernetes version.
- 2.2 Given private subnets across multiple AZs, when the EKS managed node group is created, then it spans all specified private subnets for cross-AZ distribution.
- 2.3 Given the EKS cluster and node group, when IAM roles are created, then they follow least-privilege with only the required AWS managed policies attached.
- 2.4 Given the EKS cluster is created, when cluster logging is configured, then audit, api, and authenticator log types are enabled.

---

## Requirement 3: EC2 Instance Deployment

### Description
Provision EC2 instances distributed across Availability Zones in private subnets with proper security groups and IAM profiles.

### Acceptance Criteria
- 3.1 Given an instance count and private subnets, when the EC2 module is applied, then instances are distributed across private subnets using modular index assignment (count.index % number of subnets).
- 3.2 Given EC2 security groups are created, when ingress rules are configured, then no security group rule allows unrestricted ingress (0.0.0.0/0) except where explicitly required.
- 3.3 Given EC2 instances are created, when IAM configuration is applied, then each instance has an IAM instance profile attached for AWS API access.

---

## Requirement 4: ECS Fargate Deployment

### Description
Provision an ECS cluster with Fargate tasks distributed across AZs, fronted by an Application Load Balancer.

### Acceptance Criteria
- 4.1 Given the ECS module configuration, when the ECS cluster is created, then it uses the Fargate capacity provider.
- 4.2 Given private subnets across multiple AZs, when the ECS service is created, then tasks are distributed across all specified private subnets.
- 4.3 Given public subnets, when the ALB is provisioned, then it is placed in public subnets with health checks configured on the target group.
- 4.4 Given CPU, memory, and container image inputs, when the ECS task definition is created, then it matches the specified CPU, memory, container image, and port configuration.

---

## Requirement 5: Lambda Function Deployment

### Description
Provision Lambda functions within the VPC's private subnets with proper IAM roles and CloudWatch logging.

### Acceptance Criteria
- 5.1 Given private subnets across multiple AZs, when the Lambda function is created, then its VPC configuration includes all specified private subnet IDs.
- 5.2 Given the Lambda function, when the IAM execution role is created, then it has only the minimum required policies (basic execution, VPC access, CloudWatch logs).
- 5.3 Given the Lambda function is created, when CloudWatch logging is configured, then a log group exists with a retention policy set.

---

## Requirement 6: GitHub Actions CI/CD Pipeline

### Description
Implement a GitHub Actions workflow that runs validation, linting, and security scanning on all branches, with deployment restricted to the release branch only.

### Acceptance Criteria
- 6.1 Given the GitHub Actions workflow file, when a push event occurs on any branch, then the workflow is triggered.
- 6.2 Given any branch push, when the pipeline runs, then validate (terraform validate), format check (terraform fmt -check), lint (tflint), and security scan (tfsec + checkov) jobs execute.
- 6.3 Given a push to a non-release branch, when the pipeline runs, then the deploy job is skipped entirely.
- 6.4 Given a push to the release branch, when the deploy job runs, then it requires manual approval via the production environment protection rule before applying changes.
- 6.5 Given tfsec or checkov finds critical security issues, when the security scan job runs, then the pipeline fails and blocks deployment (soft_fail is set to false).
- 6.6 Given the deploy job needs AWS access, when credentials are configured, then OIDC-based authentication is used (role-to-assume) with no long-lived credentials stored in secrets.

---

## Requirement 7: Resource Tagging and Naming

### Description
Ensure all infrastructure resources follow consistent tagging and naming conventions for operational visibility and cost tracking.

### Acceptance Criteria
- 7.1 Given any resource created by Terraform, when tags are applied, then the resource has at minimum Environment, Project, and ManagedBy tags.
- 7.2 Given any named resource, when the Name tag is set, then it follows the pattern {project_name}-{resource_type}-{identifier}.

---

## Requirement 8: Terraform Configuration and State Management

### Description
Configure Terraform with proper version constraints, provider pinning, and remote state management with locking.

### Acceptance Criteria
- 8.1 Given the backend configuration, when Terraform initializes, then state is stored in S3 with encryption enabled (encrypt = true).
- 8.2 Given the backend configuration, when Terraform initializes, then a DynamoDB table is used for state locking to prevent concurrent modifications.
- 8.3 Given the Terraform configuration, when version constraints are checked, then the required Terraform version is >= 1.7.0.
- 8.4 Given the provider configuration, when the AWS provider is initialized, then its version is pinned to ~> 5.0.

---

## Requirement 9: Self-Maintaining Documentation

### Description
Implement steering files and hooks that automatically trigger documentation updates when infrastructure code changes.

### Acceptance Criteria
- 9.1 Given a Kiro steering file exists, when its configuration is checked, then it auto-triggers on changes to .tf and .tfvars files.
- 9.2 Given a Kiro hook is configured, when a .tf file is edited, then the hook triggers a documentation update prompt.
- 9.3 Given the project structure, when each Terraform module directory is checked, then a README.md file exists documenting the module's purpose, inputs, and outputs.
