output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_app_profile.name
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_role.arn
}