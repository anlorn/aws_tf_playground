output "ec2_ips"  {
  value = data.aws_instances.this.public_ips
}
