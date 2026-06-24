output "grafana_url" {
  value = "http://${aws_instance.observability.public_ip}:3000"
}

output "prometheus_url" {
  value = "http://${aws_instance.observability.public_ip}:9090"
}

output "observability_sg_id" {
  value = aws_security_group.observability_sg.id
}

output "instance_id" {
  value = aws_instance.observability.id
}