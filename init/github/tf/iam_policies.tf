# iam_policies.tf — Policies attached to the GitHub Actions role

# Policy 1: Terraform state access (S3 + DynamoDB)
resource "aws_iam_policy" "terraform_state" {
  name        = "${var.project_name}-terraform-state-access"
  description = "Allow access to Terraform state bucket and lock table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3StateAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ]
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*",
        ]
      },
      {
        Sid    = "DynamoDBLockAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
        ]
        Resource = aws_dynamodb_table.terraform_locks.arn
      }
    ]
  })

  tags = var.tags
}

# Policy 2: Infrastructure deployment permissions
resource "aws_iam_policy" "infra_deploy" {
  name        = "${var.project_name}-infra-deploy"
  description = "Permissions for deploying the main AIOps infrastructure"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VPCNetworking"
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc", "ec2:DeleteVpc", "ec2:DescribeVpcs", "ec2:DescribeVpcAttribute", "ec2:ModifyVpcAttribute",
          "ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:DescribeSubnets",
          "ec2:DescribeAddressesAttribute",
          "ec2:CreateInternetGateway", "ec2:DeleteInternetGateway", "ec2:AttachInternetGateway", "ec2:DetachInternetGateway", "ec2:DescribeInternetGateways",
          "ec2:CreateNatGateway", "ec2:DeleteNatGateway", "ec2:DescribeNatGateways",
          "ec2:AllocateAddress", "ec2:ReleaseAddress", "ec2:DescribeAddresses",
          "ec2:CreateRouteTable", "ec2:DeleteRouteTable", "ec2:CreateRoute", "ec2:DeleteRoute", "ec2:AssociateRouteTable", "ec2:DisassociateRouteTable", "ec2:DescribeRouteTables",
          "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup", "ec2:AuthorizeSecurityGroupIngress", "ec2:AuthorizeSecurityGroupEgress", "ec2:RevokeSecurityGroupIngress", "ec2:RevokeSecurityGroupEgress", "ec2:DescribeSecurityGroups", "ec2:DescribeSecurityGroupRules",
          "ec2:CreateTags", "ec2:DeleteTags", "ec2:DescribeTags",
          "ec2:DescribeAvailabilityZones", "ec2:DescribeAccountAttributes",
          "ec2:DescribeNetworkInterfaces", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface",
        ]
        Resource = "*"
      },
      {
        Sid    = "EC2Instances"
        Effect = "Allow"
        Action = [
          "ec2:RunInstances", "ec2:TerminateInstances", "ec2:DescribeInstances", "ec2:DescribeInstanceStatus",
          "ec2:DescribeImages", "ec2:DescribeKeyPairs",
          "ec2:DescribeInstanceTypes",
        ]
        Resource = "*"
      },
      {
        Sid    = "EKS"
        Effect = "Allow"
        Action = [
          "eks:CreateCluster", "eks:DeleteCluster", "eks:DescribeCluster", "eks:UpdateClusterConfig", "eks:UpdateClusterVersion",
          "eks:CreateNodegroup", "eks:DeleteNodegroup", "eks:DescribeNodegroup", "eks:UpdateNodegroupConfig",
          "eks:TagResource", "eks:UntagResource", "eks:ListClusters", "eks:ListNodegroups",
          "eks:CreateAccessEntry", "eks:DeleteAccessEntry", "eks:DescribeAccessEntry", "eks:ListAccessEntries",
          "eks:AssociateAccessPolicy", "eks:DisassociateAccessPolicy", "eks:ListAssociatedAccessPolicies",
        ]
        Resource = "*"
      },
      {
        Sid    = "ECSFargate"
        Effect = "Allow"
        Action = [
          "ecs:CreateCluster", "ecs:DeleteCluster", "ecs:DescribeClusters",
          "ecs:CreateService", "ecs:DeleteService", "ecs:DescribeServices", "ecs:UpdateService",
          "ecs:RegisterTaskDefinition", "ecs:DeregisterTaskDefinition", "ecs:DescribeTaskDefinition", "ecs:ListTaskDefinitions",
          "ecs:TagResource", "ecs:UntagResource",
          "ecs:PutClusterCapacityProviders",
        ]
        Resource = "*"
      },
      {
        Sid    = "Lambda"
        Effect = "Allow"
        Action = [
          "lambda:CreateFunction", "lambda:DeleteFunction", "lambda:GetFunction", "lambda:UpdateFunctionCode", "lambda:UpdateFunctionConfiguration",
          "lambda:GetFunctionConfiguration", "lambda:ListFunctions",
          "lambda:AddPermission", "lambda:RemovePermission", "lambda:GetPolicy",
          "lambda:TagResource", "lambda:UntagResource", "lambda:ListTags",
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMRolesAndPolicies"
        Effect = "Allow"
        Action = [
          "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:UpdateRole", "iam:ListRoles",
          "iam:AttachRolePolicy", "iam:DetachRolePolicy", "iam:ListAttachedRolePolicies",
          "iam:PutRolePolicy", "iam:DeleteRolePolicy", "iam:GetRolePolicy", "iam:ListRolePolicies",
          "iam:CreatePolicy", "iam:DeletePolicy", "iam:GetPolicy", "iam:GetPolicyVersion", "iam:ListPolicyVersions", "iam:CreatePolicyVersion", "iam:DeletePolicyVersion",
          "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile", "iam:GetInstanceProfile", "iam:AddRoleToInstanceProfile", "iam:RemoveRoleFromInstanceProfile",
          "iam:PassRole",
          "iam:TagRole", "iam:UntagRole", "iam:TagPolicy", "iam:UntagPolicy",
          "iam:CreateServiceLinkedRole",
          "iam:ListInstanceProfilesForRole",
        ]
        Resource = "*"
      },
      {
        Sid    = "LoadBalancing"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateLoadBalancer", "elasticloadbalancing:DeleteLoadBalancer", "elasticloadbalancing:DescribeLoadBalancers", "elasticloadbalancing:ModifyLoadBalancerAttributes", "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:CreateTargetGroup", "elasticloadbalancing:DeleteTargetGroup", "elasticloadbalancing:DescribeTargetGroups", "elasticloadbalancing:ModifyTargetGroupAttributes", "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:CreateListener", "elasticloadbalancing:DeleteListener", "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:RegisterTargets", "elasticloadbalancing:DeregisterTargets", "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:AddTags", "elasticloadbalancing:RemoveTags", "elasticloadbalancing:DescribeTags",
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup", "logs:DeleteLogGroup", "logs:DescribeLogGroups",
          "logs:PutRetentionPolicy", "logs:DeleteRetentionPolicy",
          "logs:TagLogGroup", "logs:UntagLogGroup",
          "logs:TagResource", "logs:UntagResource", "logs:ListTagsForResource", "logs:ListTagsLogGroup",
        ]
        Resource = "*"
      },
    ]
  })

  tags = var.tags
}


# Attach policies to the role
resource "aws_iam_role_policy_attachment" "terraform_state" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_state.arn
}

resource "aws_iam_role_policy_attachment" "infra_deploy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.infra_deploy.arn
}
