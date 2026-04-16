# Minimal VPC to validate the GitHub Actions OIDC pipeline

resource "aws_vpc" "test" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "aiops-demo-test-vpc"
  }
}

resource "aws_subnet" "test" {
  vpc_id            = aws_vpc.test.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "aiops-demo-test-subnet"
  }
}
