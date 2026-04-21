variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "app1_target_group_arn_suffix" {
  type = string
}

variable "app2_target_group_arn_suffix" {
  type = string
}

variable "web_acl_name" {
  type = string
}

variable "alert_email" {
  type = string
}

variable "instance_ids" {
  type = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
