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