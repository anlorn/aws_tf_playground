output "ec2_arn"  {
  value = aws_instance.worker.arn

}

output "ec2_ip"  {
  value = aws_instance.worker.public_ip
}

output "ec2_password"  {
  value = aws_instance.worker.password_data

}
