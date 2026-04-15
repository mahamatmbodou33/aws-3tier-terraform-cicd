locals {
  environment = var.environment

  project_name = var.project_name

  name_prefix = "${local.project_name}-${local.environment}"

  common_tags = {
    Environment = local.environment
    Project     = local.project_name
    ManagedBy   = "Terraform"
    Owner       = "Mbodou"
  }
}