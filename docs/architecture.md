# Architecture — AIOps Demo Infrastructure

## System Overview

The AIOps demo infrastructure provisions a multi-service AWS environment using Terraform. All compute workloads run inside a shared VPC distributed across two Availability Zones for high availability. The stack includes:

- **VPC** with public and private subnets, internet gateway, and a single shared NAT gateway
- **EKS** managed Kubernetes cluster with node groups in private subnets
- **EC2** instances distributed across private subnets with IAM instance profiles
- **ECS Fargate** cluster with an Application Load Balancer in public subnets
- **Lambda** function attached to VPC private subnets
- **AgentCore** Bedrock AgentCore Runtime for deploying AI agents in VPC private subnets

A GitHub Actions CI/CD pipeline validates, scans, and deploys the infrastructure. Authentication to AWS uses GitHub OIDC — no long-lived credentials are stored.

## Architecture Diagram

```mermaid
graph TD
    subgraph "GitHub"
        REPO[GitHub Repository]
        GHA[GitHub Actions CI/CD]
    end

    subgraph "Terraform State"
        S3[S3 Backend<br/>Encrypted]
        DDB[DynamoDB<br/>State Locking]
    end

    subgraph "ECR"
        ECR_EKS[EKS Repos<br/>api-gateway, cat-profile]
        ECR_ECS[ECS Repos<br/>feeding-service, health-monitor<br/>chatbot-ui, device-simulator<br/>admin-console]
        ECR_LAMBDA[Lambda Repo<br/>device-service]
        ECR_AGENT[AgentCore Repos<br/>langgraph-agent, strands-agents]
    end

    subgraph "AWS VPC 10.0.0.0/16"
        IGW[Internet Gateway]

        NAT[NAT Gateway<br/>Single shared]

        subgraph "AZ-a us-east-1a"
            PUB_A[Public Subnet<br/>10.0.1.0/24]
            PRIV_A[Private Subnet<br/>10.0.10.0/24]
            EKS_A[EKS Node]
            EC2_A[EC2 Instance]
            ECS_A[ECS Fargate Task]
        end

        subgraph "AZ-b us-east-1b"
            PUB_B[Public Subnet<br/>10.0.2.0/24]
            PRIV_B[Private Subnet<br/>10.0.20.0/24]
            EKS_B[EKS Node]
            EC2_B[EC2 Instance]
            ECS_B[ECS Fargate Task]
        end

        ALB[Application Load Balancer]
        LAMBDA[Lambda Function]
        AGENTCORE[AgentCore Runtime]
    end

    REPO --> GHA
    GHA -->|OIDC Auth| S3
    GHA --> DDB
    GHA -->|terraform apply| IGW

    IGW --> PUB_A
    IGW --> PUB_B
    PUB_A --> NAT
    NAT --> PRIV_A
    NAT --> PRIV_B

    ALB --> PUB_A
    ALB --> PUB_B
    ALB --> ECS_A
    ALB --> ECS_B

    PRIV_A --> EKS_A
    PRIV_A --> EC2_A
    PRIV_A --> ECS_A
    PRIV_A --> LAMBDA
    PRIV_A --> AGENTCORE

    PRIV_B --> EKS_B
    PRIV_B --> EC2_B
    PRIV_B --> ECS_B
    PRIV_B --> LAMBDA
    PRIV_B --> AGENTCORE

    ECR_EKS --> EKS_A
    ECR_EKS --> EKS_B
    ECR_ECS --> ECS_A
    ECR_ECS --> ECS_B
    ECR_LAMBDA --> LAMBDA
    ECR_AGENT --> AGENTCORE
```

## Module Descriptions

### ECR (`./modules/ecr`)

Provisions ECR repositories for all application container images. Each repository is created with scan-on-push enabled, AES256 encryption, and a lifecycle policy to retain a configurable number of images. Repositories are grouped under the `{project_name}/` prefix and tagged with their compute target for traceability.

| Repository | Service | Compute Target |
|---|---|---|
| `cat-demo/api-gateway` | API Gateway Service (Spring Boot) | EKS |
| `cat-demo/cat-profile` | Cat Profile Service (Spring Boot) | EKS |
| `cat-demo/feeding-service` | Feeding Service (Django) | ECS Fargate |
| `cat-demo/health-monitor` | Health Monitor Service (Django) | ECS Fargate |
| `cat-demo/device-service` | Device Service (Go) | Lambda |
| `cat-demo/chatbot-ui` | Chatbot UI (React) | ECS Fargate |
| `cat-demo/device-simulator` | Device Simulator (React) | ECS Fargate |
| `cat-demo/admin-console` | Admin Console (React) | ECS Fargate |
| `cat-demo/langgraph-agent` | LangGraph Workflow Agent (Python) | AgentCore Runtime |
| `cat-demo/strands-agents` | Strands Multi-Agent System (Python) | AgentCore Runtime |

**Key resources:** ECR repositories, ECR lifecycle policies.

### VPC (`terraform-aws-modules/vpc/aws ~> 5.0`)

Provisions the shared networking foundation. Creates a VPC with DNS support, public and private subnets across two AZs, an internet gateway, and a single shared NAT gateway. Public subnets route outbound traffic through the internet gateway. Private subnets route outbound traffic through the shared NAT gateway.

**Key resources:** VPC, public subnets, private subnets, internet gateway, NAT gateway, Elastic IP, route tables.

### EKS (`terraform-aws-modules/eks/aws ~> 20.0`)

Deploys an Amazon EKS cluster with a managed node group. The cluster control plane and nodes run in private subnets. Cluster logging is enabled for audit, API, and authenticator events. Node group scaling is configurable via min/max/desired size variables.

**Key resources:** EKS cluster, managed node group, IAM roles, security groups, CloudWatch log groups.

### EC2 (`./modules/ec2`)

Provisions EC2 instances distributed across private subnets using modular index assignment (`count.index % length(subnet_ids)`). Each instance has an IAM instance profile with SSM access and a security group that restricts SSH ingress to the VPC CIDR. IMDSv2 is enforced and root volumes are encrypted.

**Key resources:** EC2 instances, security group, IAM role, IAM instance profile.

### ECS (`./modules/ecs`)

Runs containerized workloads on ECS Fargate. The cluster uses the Fargate capacity provider. Tasks run in private subnets and are fronted by an Application Load Balancer in public subnets. Container logs are sent to CloudWatch. The ALB performs HTTP health checks against the target group.

**Key resources:** ECS cluster, task definition, ECS service, ALB, target group, listener, security groups, IAM task execution role, CloudWatch log group.

### Lambda (`./modules/lambda`)

Deploys a VPC-attached Lambda function in private subnets. The function has its own security group (egress-only) and an IAM execution role with basic execution and VPC access policies. Source code is packaged from `modules/lambda/src/` and CloudWatch log retention is set to 14 days.

**Key resources:** Lambda function, IAM role, security group, CloudWatch log group.

### ECR (`./modules/ecr`)

Provisions ECR repositories for all application container images. Each repository is named `{project_name}/{suffix}` and configured with image scanning on push and AES256 encryption. A lifecycle policy on each repository expires images beyond a configurable count to control storage costs.

**Key resources:** ECR repositories, ECR lifecycle policies.

### AgentCore (`./modules/agentcore`)

Deploys an Amazon Bedrock AgentCore Runtime for running AI agents in VPC private subnets. The module provisions an ECR repository for agent container images, a security group (egress-only), and an IAM role trusted by the `bedrock-agentcore.amazonaws.com` service with ECR pull and Bedrock access permissions. The runtime uses container-based deployment and supports HTTP, MCP, and A2A protocols. Session lifecycle is configurable via idle timeout and max lifetime variables.

**Key resources:** AgentCore runtime, ECR repository, ECR lifecycle policy, security group, IAM role, CloudWatch log group.

## CI/CD Pipeline Overview

The GitHub Actions workflow (`.github/workflows/terraform.yml`) runs on every push to any branch:

```mermaid
flowchart TD
    PUSH[Git Push] --> VALIDATE[Validate & Lint]
    VALIDATE --> FMT[terraform fmt -check]
    FMT --> INIT[terraform init -backend=false]
    INIT --> VAL[terraform validate]

    VAL --> BRANCH{Release branch?}
    BRANCH -->|No| DONE[Pipeline Complete]
    BRANCH -->|Yes| DEPLOY[Deploy Infrastructure]
    DEPLOY --> CREDS[Configure AWS via OIDC]
    CREDS --> PLAN[terraform plan]
    PLAN --> APPLY[terraform apply]
```

- **All branches:** Format check, init (no backend), and validate.
- **Release branch only:** Full deploy with AWS OIDC authentication, plan, and apply.
- The `production` GitHub environment can be configured with required reviewers for manual approval before apply.

## Security Model

### Authentication

- **GitHub OIDC:** GitHub Actions authenticates to AWS using short-lived OIDC tokens. The IAM role trust policy is scoped to a specific repository and branch. No long-lived AWS credentials are stored in GitHub secrets.
- The OIDC provider and deploy role are bootstrapped separately via `init/github/tf/`.

### Network Security

- **Private subnets:** All compute resources (EKS nodes, EC2 instances, ECS tasks, Lambda, AgentCore runtime) run in private subnets with no direct internet access.
- **NAT egress only:** Private subnet resources reach the internet through a single shared NAT gateway (outbound only).
- **Security groups:** Default deny-all with explicit allow rules. Only the ECS ALB security group allows inbound HTTP (port 80) from the internet. EC2 SSH is restricted to the VPC CIDR.

### IAM — Least Privilege

- Each service has its own IAM role with only the permissions it needs:
  - **EKS:** Cluster role and node group role with AWS-managed EKS policies.
  - **EC2:** Instance profile with SSM managed instance core policy.
  - **ECS:** Task execution role with the ECS task execution policy.
  - **Lambda:** Execution role with basic execution and VPC access policies.
  - **AgentCore:** Runtime role trusted by `bedrock-agentcore.amazonaws.com` with ECR pull and Bedrock access policies.

### State Security

- Terraform state is stored in S3 with server-side encryption enabled (`encrypt = true`).
- DynamoDB provides state locking to prevent concurrent modifications.
- The state bucket has versioning enabled and public access blocked.
