terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0, < 7.0.0"
    }
  }

  # Backend is configured per-environment via `-backend-config` at `terraform init`.
  # See environments/<env>/backend.hcl and .github/workflows/terraform.yml.
  # Required keys: bucket, key, region, dynamodb_table, encrypt.
  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "aiops-demo"
      ManagedBy   = "terraform"
      Environment = "dev"
    }
  }
}
