#########################################################
# Environment: DEV
#
# Deploy SCALE BaT databases
#########################################################
terraform {
  backend "s3" {
    bucket         = "scale-terraform-state"
    key            = "ccs-scale-infra-db-bat-sbx2"
    region         = "eu-west-2"
    dynamodb_table = "scale_terraform_state_lock"
    encrypt        = true
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

locals {
  environment        = "SBX2"
  availability_zones = ["eu-west-2a", "eu-west-2b"]
}

data "aws_ssm_parameter" "aws_account_id" {
  name = "account-id-${lower(local.environment)}"
}

data "aws_ssm_parameter" "kms_cmk_rds_shared" {
  name = "kms-cmk-rds-shared"
}

module "deploy" {
  source                          = "../../modules/configs/deploy-all"
  aws_account_id                  = data.aws_ssm_parameter.aws_account_id.value
  environment                     = local.environment
  availability_zones              = local.availability_zones
  deletion_protection             = false
  skip_final_snapshot             = false
  enabled_cloudwatch_logs_exports = ["postgresql"]
  kms_cmk_rds_shared              = data.aws_ssm_parameter.kms_cmk_rds_shared.value
  snapshot_identifier             = "arn:aws:rds:eu-west-2:${data.aws_ssm_parameter.aws_account_id.value}:cluster-snapshot:scale-bat-spree-seeded"
}
