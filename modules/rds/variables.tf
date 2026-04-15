variable "db_subnets" { type = list(string) }
variable "db_sg_id" {}
variable "name" {
  type = string
}
variable "tags" {
  type = map(string)
}