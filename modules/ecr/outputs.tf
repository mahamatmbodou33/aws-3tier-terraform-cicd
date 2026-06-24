output "app1_repository_name" {
  value = aws_ecr_repository.app1.name
}

output "app2_repository_name" {
  value = aws_ecr_repository.app2.name
}

output "app1_repository_url" {
  value = aws_ecr_repository.app1.repository_url
}

output "app2_repository_url" {
  value = aws_ecr_repository.app2.repository_url
}