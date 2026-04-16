terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # This bootstrap project uses LOCAL state intentionally.
  # It must exist before the S3 backend is available.
  # State file should be committed or stored securely.
}

provider "aws" {
  profile = "cloudops-demo"
  region  = "us-east-1"

  default_tags {
    tags = var.tags
  }
}
