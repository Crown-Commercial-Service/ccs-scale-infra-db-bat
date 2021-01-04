variable "aws_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "deletion_protection" {
  type = bool
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "enabled_cloudwatch_logs_exports" {
  type = list(string)
}

variable "backup_retention_period" {
  type    = number
  default = 1
}

variable "spree_cluster_instances" {
  type    = number
  default = 1
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.large"
}

variable "es_instance_type" {
  type    = string
  default = "t2.medium.elasticsearch"
}

variable "es_ebs_volume_size" {
  type    = number
  default = 10
}

#####################################
# Override this if you want to create
# a new database from a snapshot
#####################################
variable "snapshot_identifier" {
  type    = string
  default = ""
}

variable "kms_cmk_rds_shared" {
  type = string
}
