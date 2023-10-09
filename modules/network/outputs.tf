output "vpc_arn" {
  description = "ARN of VPC"
  value = aws_vpc.this.arn
}

output "public_subnet_id"  {
  description = "ID of public subnet"
  value = aws_subnet.public.id
}

output "allow_ssh_sg_id"  {
  description = "ID of SG which allows SSH"
  value = aws_security_group.this.id
}

output "allow_ssh_sg_name"  {
  description = "Name of SG which allows SSH"
  value = aws_security_group.this.name
}
