variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "alb_sg_id" {}
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