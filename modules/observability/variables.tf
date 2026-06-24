variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "my_ip_cidr" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "gmail_app_password" {
  description = "Gmail app password for Alertmanager SMTP"
  type        = string
  sensitive   = true
}