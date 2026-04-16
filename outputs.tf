output "vpc_id" {
  description = "ID of the test VPC"
  value       = aws_vpc.test.id
}

output "subnet_id" {
  description = "ID of the test subnet"
  value       = aws_subnet.test.id
}
