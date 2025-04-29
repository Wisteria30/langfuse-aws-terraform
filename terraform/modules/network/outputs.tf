output "vpc_id" {
  description = "再作成された (または既存) デフォルト VPC ID"
  value       = aws_default_vpc.this.id
}

output "public_subnet_ids" {
  description = "各 AZ に作成されたデフォルトサブネット ID"
  value = [
    aws_default_subnet.az_a.id,
    aws_default_subnet.az_c.id
  ]
}

output "private_subnet_ids" {
  description = "各 AZ に作成されたプライベートサブネット ID"
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id
  ]
}