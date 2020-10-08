variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "es_instance_type" {
  type = string
}

variable "es_ebs_volume_size" {
  type = number
}