#########################################################
# Config: deploy-all
#
# This configuration will deploy all components.
#########################################################
provider "aws" {
  profile = "default"
  region  = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/CCS_SCALE_Build"
  }
}

data "aws_ssm_parameter" "vpc_id" {
  name = "${lower(var.environment)}-vpc-id"
}

data "aws_ssm_parameter" "private_db_subnet_ids" {
  name = "${lower(var.environment)}-private-db-subnet-ids"
}

data "aws_ssm_parameter" "private_app_subnet_ids" {
  name = "${lower(var.environment)}-private-app-subnet-ids"
}

data "aws_ssm_parameter" "public_web_subnet_ids" {
  name = "${lower(var.environment)}-public-web-subnet-ids"
}

data "aws_ssm_parameter" "aurora_kms_key_arn" {
  name = "${lower(var.environment)}-aurora-encryption-key"
}

######################################
# CIDR ranges for whitelisting
######################################
data "aws_ssm_parameter" "cidr_blocks_allowed_external_ccs" {
  name = "${lower(var.environment)}-cidr-blocks-allowed-external-ccs"
}

data "aws_ssm_parameter" "cidr_blocks_allowed_external_spark" {
  name = "${lower(var.environment)}-cidr-blocks-allowed-external-spark"
}

data "aws_ssm_parameter" "cidr_blocks_allowed_external_cognizant" {
  name = "${lower(var.environment)}-cidr-blocks-allowed-external-cognizant"
}

data "aws_vpc" "scale" {
  id = data.aws_ssm_parameter.vpc_id.value
}

locals {
  # Normalised CIDR blocks (accounting for 'none' i.e. "-" as value in SSM parameter)
  cidr_blocks_allowed_external_ccs       = data.aws_ssm_parameter.cidr_blocks_allowed_external_ccs.value != "-" ? split(",", data.aws_ssm_parameter.cidr_blocks_allowed_external_ccs.value) : []
  cidr_blocks_allowed_external_spark     = data.aws_ssm_parameter.cidr_blocks_allowed_external_spark.value != "-" ? split(",", data.aws_ssm_parameter.cidr_blocks_allowed_external_spark.value) : []
  cidr_blocks_allowed_external_cognizant = data.aws_ssm_parameter.cidr_blocks_allowed_external_cognizant.value != "-" ? split(",", data.aws_ssm_parameter.cidr_blocks_allowed_external_cognizant.value) : []
}

module "spree" {
  source                          = "../../spree"
  environment                     = var.environment
  vpc_id                          = data.aws_ssm_parameter.vpc_id.value
  availability_zones              = var.availability_zones
  private_db_subnet_ids           = split(",", data.aws_ssm_parameter.private_db_subnet_ids.value)
  deletion_protection             = var.deletion_protection
  skip_final_snapshot             = var.skip_final_snapshot
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  backup_retention_period         = var.backup_retention_period
  cluster_instances               = var.spree_cluster_instances
  db_instance_class               = var.db_instance_class
  snapshot_identifier             = var.snapshot_identifier
  # kms_key_id                      = data.aws_ssm_parameter.aurora_kms_key_arn.value
  kms_key_id = "arn:aws:kms:eu-west-2:016776319009:key/a9cd5472-9afc-472e-8e15-665695f7a84b"
}

module "elasticsearch" {
  source                 = "../../elasticsearch"
  environment            = var.environment
  vpc_id                 = data.aws_ssm_parameter.vpc_id.value
  private_app_subnet_ids = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  security_group_ids     = concat(local.cidr_blocks_allowed_external_ccs, local.cidr_blocks_allowed_external_spark, tolist([data.aws_vpc.scale.cidr_block]))
  es_instance_type       = var.es_instance_type
  es_ebs_volume_size     = var.es_ebs_volume_size
}
