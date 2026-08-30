variable "vpc_id" {
  type = string
}
variable "public_subnets" {
  type = list(string)
}
variable "alb_sg_id" {
  type = string
}
variable "tags" {
  type = map(string)
}
variable "name" {
  type = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
}
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}