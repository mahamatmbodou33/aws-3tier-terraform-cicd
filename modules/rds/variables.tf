variable "db_subnets" { type = list(string) }
variable "db_sg_id" {}
variable "name" {
  type = string
}
variable "tags" {
  type = map(string)
}
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}
variable "db_password" {
  description = "Master password for the RDS instance (inject via TF_VAR_db_password, never commit a literal)"
  type        = string
  sensitive   = true
}
variable "multi_az" {
  description = "Whether to deploy the RDS instance across two AZs for high availability"
  type        = bool
  default     = false
}
