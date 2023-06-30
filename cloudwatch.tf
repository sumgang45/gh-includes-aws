
resource "aws_cloudwatch_log_group" "example" {
  name = "/aws/nonaws/ip-${random_string.suffix.result}"
}

resource "aws_cloudwatch_log_metric_filter" "nonawsip" {
  depends_on = [
    aws_instance.wb, aws_cloudwatch_log_group.example
  ]
  name           = "non-aws-ip"
  pattern        = "{ ($.userIdentity.type = \"AssumedRole\" )  && ( ($.sourceIPAddress != \"AWS Internal\" ) && ($.sourceIPAddress != \"cloudtrail.amazonaws.com\" ) )}"
  log_group_name = aws_cloudwatch_log_group.example.name
  metric_transformation {
    name      = "Non-AWS_IP"
    namespace = "Trail"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "sshec2fail" {
  depends_on = [
    aws_cloudwatch_log_group.example, aws_cloudwatch_log_metric_filter.nonawsip
  ]
  alarm_name                = "Non-AWS-IP-Alarm-${random_string.suffix.result}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "Non-AWS_IP"
  namespace                 = "Trail"
  period                    = "900"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors Non AWS IP based on Cloud trail"
  insufficient_data_actions = []
}
