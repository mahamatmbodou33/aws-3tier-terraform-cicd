resource "aws_sns_topic" "alerts" {
  name = "waf-alerts-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "waf_blocked" {
  alarm_name          = "waf-blocked-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 1
  period              = 60

  namespace  = "AWS/WAFV2"
  metric_name = "BlockedRequests"

  dimensions = {
    WebACL = var.web_acl_name
    Region = var.region
  }

  statistic = "Sum"

  alarm_actions = [aws_sns_topic.alerts.arn]
}