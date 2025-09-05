output "instance_hostname" {
  description = "Private DNS name of EC2 Instance"
  value       = aws_instance.private_app_server.private_dns
}
