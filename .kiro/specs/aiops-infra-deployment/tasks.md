# Tasks: AIOps Infrastructure Deployment

## Task 1: Project Scaffolding and Configuration Updates
- [x] 1.1 `providers.tf` already exists with Terraform >= 1.7.0, AWS provider ~> 5.0, S3 backend
- [x] 1.2 `.gitignore` already exists with Terraform ignore patterns
- [x] 1.3 Create `variables.tf` at root level with all input variable declarations (project_name, aws_region, vpc_cidr, availability_zones, subnet CIDRs, EKS/EC2/ECS/Lambda config, tags)
- [x] 1.4 Create `outputs.tf` at root level exposing key outputs from all modules
- [x] 1.5 Create `environments/dev/terraform.tfvars` with development environment values
- [x] 1.6 Create `environments/prod/terraform.tfvars` with production environment values

## Task 2: VPC using terraform-aws-modules/vpc/aws
- [x] 2.1 Add `terraform-aws-modules/vpc/aws` module to `main.tf` with VPC CIDR, 2 AZs, public and private subnets, NAT gateways (one per AZ), DNS support enabled
- [x] 2.2 Wire VPC module outputs (vpc_id, public_subnet_ids, private_subnet_ids) to root outputs

## Task 3: EKS using terraform-aws-modules/eks/aws
- [x] 3.1 Add `terraform-aws-modules/eks/aws` module to `main.tf` with cluster version, VPC ID, private subnet IDs from VPC module
- [x] 3.2 Configure managed node group with configurable instance types and scaling (min/max/desired), distributed across private subnets
- [x] 3.3 Enable cluster logging (audit, api, authenticator)
- [x] 3.4 Wire EKS module outputs (cluster_endpoint, cluster_name) to root outputs

## Task 4: EC2 Instances (custom module — no mature open-source wrapper)
- [x] 4.1 Create `modules/ec2/main.tf` with EC2 instances distributed across private subnets using count.index % length(subnet_ids)
- [x] 4.2 Create `modules/ec2/variables.tf` with inputs: project_name, vpc_id, private_subnet_ids, instance_type, instance_count, ami_id, tags
- [x] 4.3 Add security group with no unrestricted ingress and IAM instance profile
- [x] 4.4 Create `modules/ec2/outputs.tf` exposing instance_ids, private_ips, security_group_id
- [x] 4.5 Wire EC2 module in `main.tf` with data source for Amazon Linux 2023 AMI

## Task 5: ECS Fargate (custom module)
- [x] 5.1 Create `modules/ecs/main.tf` with ECS cluster (Fargate capacity provider), task definition, service across private subnets
- [x] 5.2 Create `modules/ecs/variables.tf` with inputs: project_name, vpc_id, private_subnet_ids, public_subnet_ids, container config, tags
- [x] 5.3 Add ALB in public subnets with target group, health checks, and security groups (ALB: 80/443 from internet, tasks: from ALB only)
- [x] 5.4 Add IAM task execution role and CloudWatch log group
- [x] 5.5 Create `modules/ecs/outputs.tf` exposing cluster_id, service_name, alb_dns_name
- [x] 5.6 Wire ECS module in `main.tf`

## Task 6: Lambda Function (custom module)
- [x] 6.1 Create `modules/lambda/main.tf` with Lambda function attached to VPC private subnets, IAM execution role, security group, CloudWatch log group
- [x] 6.2 Create `modules/lambda/variables.tf` with inputs: project_name, vpc_id, private_subnet_ids, function_name, runtime, handler, memory_size, timeout, tags
- [x] 6.3 Create placeholder source code in `modules/lambda/src/main.py`
- [x] 6.4 Create `modules/lambda/outputs.tf` exposing function_arn, function_name, invoke_arn
- [x] 6.5 Wire Lambda module in `main.tf`

## Task 7: CI/CD Pipeline Updates
- [x] 7.1 `.github/workflows/terraform.yml` already exists with validate, security scan (tfsec hard fail, checkov soft fail), and deploy with manual approval
- [x] 7.2 Verify pipeline works with the new module structure (terraform init downloads open-source modules)

## Task 8: Self-Maintaining Documentation
- [x] 8.1 Create `.kiro/steering/infra-docs.md` steering file with auto inclusion on .tf and .tfvars file globs
- [x] 8.2 Create Kiro hook that triggers documentation update prompt when .tf files are edited
- [x] 8.3 Create `docs/architecture.md` with high-level architecture documentation
- [x] 8.4 Create root `README.md` with project overview, prerequisites, setup guide, and usage instructions
