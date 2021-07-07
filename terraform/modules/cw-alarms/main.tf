#########################################################
# Cloudwatch: Alarms
#
# Create performance alarms.
#########################################################

resource "aws_sns_topic" "alarms" {
  name              = "CCS-EU2-${upper(var.environment)}-CW-ALARMS-${upper(var.db_name)}-DB"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_cloudwatch_metric_alarm" "task" {
  alarm_name                = "${lower(var.db_name)}-db-task-alarm"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "5"
  datapoints_to_alarm       = "3"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = "60"
  statistic                 = "SampleCount"
  threshold                 = var.db_expected_instance_count
  alarm_description         = "This metric monitors task removals"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBClusterIdentifier = var.db_cluster_name
  }
}
