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
# variable "vpc_id" {
#   description = "VPC ID for app resources"
#   type        = string
# }
# variable "private_subnets" { type = list(string) }

# # variable "name" {
# #   description = "Name for the app resources"
# #   type = string
# # }
# variable "tags" {
#   description = "Tags for the app resources"
#   type = map(string)
# }
# variable "iam_instance_profile" {
#   description = "IAM instance profile for EC2"
#   type        = string
# }

# # Optional variables for app configuration
# variable "app_name" {
#   description = "Name of the application"

# }
# variable "app_message" {
#   description = "Message for the application"
#   type = string
# }
# variable "app_port" {
#   description = "Port for the application"

# }
# variable "ami_id" {
#   description = "AMI ID for the app instances"
#   type = string
# }
# variable "app_sg_id" {
#   description = "Security group ID for the app instances"
#   type = string
# }
# variable "target_group_arn" {
#   type = string
# }
# # ci/cd variable
# variable "app_version" {
#   description = "Application version from CI/CD"
#   type        = string
# }



