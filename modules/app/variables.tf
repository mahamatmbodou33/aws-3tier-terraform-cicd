variable "name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "desired_capacity" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "instance_profile_name" {
  type = string
}

variable "artifact_bucket" {
  type = string
}

variable "artifact_key" {
  type = string
}

variable "app_name" {
  type = string
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "user_data_extra" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "ecr_repo" {
  type = string
}