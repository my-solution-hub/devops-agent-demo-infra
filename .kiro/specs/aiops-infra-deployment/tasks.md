# Tasks: AIOps Infrastructure Deployment

## Task 1: Project Scaffolding and Terraform Configuration
- [ ] 1.1 Create the project directory structure (root files, modules/, environments/, docs/, .github/workflows/)
- [ ] 1.2 Create `providers.tf` with Terraform >= 1.7.0 version constraint and AWS provider ~> 5.0 with default tags
- [ ] 1.3 Create `backend.tf` with S3 backend configuration (bucket, key, region, DynamoDB table, encrypt = true)
- [ ] 1.4 Create `variables.tf` at root level with all input variable declarations and validation rules
- [ ] 1.5 Create `outputs.tf` at root level exposing key outputs from all modules
- [ ] 1.6 Create `environments/dev/terraform.tfvars` with development environment values
- [ ] 1.7 Create `environments/prod/terraform.tfvars` with production environment values
- [ ] 1.8 Create `.gitignore` with Terraform-specific ignore patterns (.terraform/, *.tfstate, *.tfplan, etc.)

## Task 2: VPC Module Implementation
- [ ] 2.1 Create `modules/vpc/variables.tf` with inputs: project_name, vpc_cidr, availability_zones, public_subnet_cidrs, private_subnet_cidrs, tags (with CIDR validation rules)
- [ ] 2.2 Create `modules/vpc/main.tf` with VPC resource (DNS support and hostnames enabled)
- [ ] 2.3 Add public and private subnet resources using count based on availability_zones length, with proper AZ assignment and tagging
- [ ] 2.4 Add internet gateway resource attached to the VPC
- [ ] 2.5 Add Elastic IPs and NAT gateway resources (one per AZ) in public subnets
- [ ] 2.6 Add route tables: public route table with 0.0.0.0/0 → IGW, private route tables (one per AZ) with 0.0.0.0/0 → NAT gateway
- [ ] 2.7 Add route table associations for public and private subnets
- [ ] 2.8 Create `modules/vpc/outputs.tf` exposing vpc_id, public_subnet_ids, private_subnet_ids, nat_gateway_ids
- [ ] 2.9 Create `modules/vpc/README.md` documenting the module's purpose, inputs, and outputs

## Task 3: EKS Module Implementation
- [ ] 3.1 Create `modules/eks/variables.tf` with inputs: project_name, vpc_id, private_subnet_ids, cluster_version, node_instance_types, node sizing (min/max/desired), tags
- [ ] 3.2 Create `modules/eks/main.tf` with EKS cluster resource, specifying Kubernetes version and private subnet IDs
- [ ] 3.3 Add IAM role and policies for the EKS cluster (AmazonEKSClusterPolicy) with least-privilege
- [ ] 3.4 Add EKS managed node group spanning all private subnets with configurable instance types and scaling
- [ ] 3.5 Add IAM role and policies for the node group (AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly)
- [ ] 3.6 Add cluster security group configuration
- [ ] 3.7 Enable cluster logging for audit, api, and authenticator log types
- [ ] 3.8 Create `modules/eks/outputs.tf` exposing cluster_endpoint, cluster_name, cluster_security_group_id, node_group_role_arn
- [ ] 3.9 Create `modules/eks/README.md` documenting the module

## Task 4: EC2 Module Implementation
- [ ] 4.1 Create `modules/ec2/variables.tf` with inputs: project_name, vpc_id, private_subnet_ids, instance_type, instance_count, ami_id, key_name, tags
- [ ] 4.2 Create `modules/ec2/main.tf` with EC2 instances distributed across private subnets using count.index % length(subnet_ids)
- [ ] 4.3 Add security group with no unrestricted ingress (no 0.0.0.0/0 ingress rules)
- [ ] 4.4 Add IAM instance profile and role for EC2 instances
- [ ] 4.5 Create `modules/ec2/outputs.tf` exposing instance_ids, private_ips, security_group_id
- [ ] 4.6 Create `modules/ec2/README.md` documenting the module

## Task 5: ECS Module Implementation
- [ ] 5.1 Create `modules/ecs/variables.tf` with inputs: project_name, vpc_id, private_subnet_ids, public_subnet_ids, container_image, container_port, task_cpu, task_memory, desired_count, tags
- [ ] 5.2 Create `modules/ecs/main.tf` with ECS cluster using Fargate capacity provider
- [ ] 5.3 Add ECS task definition with container configuration (image, port, CPU, memory) and CloudWatch log group
- [ ] 5.4 Add ECS service distributing tasks across all private subnets
- [ ] 5.5 Add Application Load Balancer in public subnets with target group and health check configuration
- [ ] 5.6 Add security groups for ALB (allow 80/443 from internet) and ECS tasks (allow traffic from ALB only)
- [ ] 5.7 Add IAM task execution role with least-privilege policies
- [ ] 5.8 Create `modules/ecs/outputs.tf` exposing cluster_id, service_name, alb_dns_name, task_definition_arn
- [ ] 5.9 Create `modules/ecs/README.md` documenting the module

## Task 6: Lambda Module Implementation
- [ ] 6.1 Create `modules/lambda/variables.tf` with inputs: project_name, vpc_id, private_subnet_ids, function_name, runtime, handler, memory_size, timeout, environment_variables, tags
- [ ] 6.2 Create `modules/lambda/main.tf` with Lambda function attached to VPC using all private subnet IDs
- [ ] 6.3 Add IAM execution role with minimum required policies (AWSLambdaBasicExecutionRole, AWSLambdaVPCAccessExecutionRole)
- [ ] 6.4 Add security group for Lambda VPC network access
- [ ] 6.5 Add CloudWatch log group with retention policy
- [ ] 6.6 Create placeholder Lambda source code in `modules/lambda/lambda_src/main.py`
- [ ] 6.7 Create `modules/lambda/outputs.tf` exposing function_arn, function_name, invoke_arn, security_group_id
- [ ] 6.8 Create `modules/lambda/README.md` documenting the module

## Task 7: Root Module Composition
- [ ] 7.1 Create `main.tf` composing all five modules (vpc, eks, ec2, ecs, lambda) with proper variable bindings
- [ ] 7.2 Wire VPC outputs (vpc_id, subnet IDs) as inputs to EKS, EC2, ECS, and Lambda modules
- [ ] 7.3 Add data source for Amazon Linux 2023 AMI (used by EC2 module)
- [ ] 7.4 Verify all module dependencies are expressed through output references (no explicit depends_on needed)

## Task 8: GitHub Actions CI/CD Pipeline
- [ ] 8.1 Create `.github/workflows/terraform.yml` with trigger on push to all branches and PRs to release
- [ ] 8.2 Add `validate` job: checkout, setup Terraform, terraform fmt -check -recursive, terraform init -backend=false, terraform validate, setup and run tflint
- [ ] 8.3 Add `security` job (depends on validate): run tfsec-action and checkov-action with soft_fail: false
- [ ] 8.4 Add `deploy` job (depends on validate + security): conditional on refs/heads/release, uses production environment for manual approval
- [ ] 8.5 Configure deploy job steps: configure AWS credentials via OIDC (role-to-assume), terraform init, terraform plan -out=tfplan, terraform apply -auto-approve tfplan
- [ ] 8.6 Add workflow-level permissions (id-token: write, contents: read, pull-requests: write) and environment variables (TF_VERSION, AWS_REGION)

## Task 9: Linting and Security Configuration
- [ ] 9.1 Create `.tflint.hcl` configuration file with AWS plugin and recommended rules
- [ ] 9.2 Verify all modules pass `terraform fmt -check` formatting standards
- [ ] 9.3 Verify all modules pass `terraform validate` independently

## Task 10: Self-Maintaining Documentation
- [ ] 10.1 Create `.kiro/steering/infra-docs.md` steering file with auto inclusion on .tf and .tfvars file globs
- [ ] 10.2 Create Kiro hook that triggers documentation update prompt when .tf files are edited
- [ ] 10.3 Create `docs/architecture.md` with high-level architecture documentation
- [ ] 10.4 Create `docs/modules.md` with module reference documentation (inputs, outputs, usage for each module)
- [ ] 10.5 Create `docs/runbook.md` with operational runbook (deployment, troubleshooting, rollback procedures)
- [ ] 10.6 Create root `README.md` with project overview, prerequisites, setup guide, and usage instructions

## Task 11: Tagging and Naming Verification
- [ ] 11.1 Verify all resources across all modules include merge(var.tags, {...}) for consistent tagging
- [ ] 11.2 Verify all Name tags follow the {project_name}-{resource_type}-{identifier} pattern
- [ ] 11.3 Verify default_tags in the provider configuration includes Environment, Project, and ManagedBy
