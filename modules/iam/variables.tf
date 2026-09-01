variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "artifact_bucket_arn" {
  type = string
}

variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}
variable "create_oidc_provider" {
  description = "Whether this environment creates the GitHub OIDC provider (account-level singleton - only one environment should own it)"
  type = bool
  default = true
}

variable "aws_region" {
  description = "Region used to build service ARNs for scoping the CI policy"
  type        = string
}

variable "tf_state_bucket_name" {
  description = "Name of the S3 bucket holding Terraform remote state, used to scope the CI policy"
  type        = string
  default     = "three-tier-app-terraform-state-12345"
}

variable "tf_lock_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking, used to scope the CI policy"
  type        = string
  default     = "terraform-locks"
}
