# Create new file: module/Monitoring/main.tf
resource "aws_cloudwatch_dashboard" "mongodb_dashboard" {
  dashboard_name = "${var.PROJECT_NAME}-mongodb-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.MONGOS_1_ID],
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.MONGOS_2_ID]
          ]
          period = 300
          stat   = "Average"
          region = var.REGION
          title  = "MongoDB Router CPU"
        }
      },
      # Add more widgets for memory, disk, connections, etc.
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "mongodb_disk_space_alarm" {
  alarm_name          = "${var.PROJECT_NAME}-disk-space-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "DiskSpaceUtilization"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "10"  # Alert when 10% space remaining
  alarm_description   = "This alarm monitors MongoDB disk space"
  alarm_actions       = [aws_sns_topic.mongodb_alerts.arn]
  dimensions = {
    InstanceId = var.MONGOS_1_ID  # Using the first mongos instance for monitoring
    # Add dimensions for each MongoDB instance
  }
}

resource "aws_sns_topic" "mongodb_alerts" {
  name = "${var.PROJECT_NAME}-alerts"
}

resource "aws_sns_topic_subscription" "mongodb_alerts_email" {
  topic_arn = aws_sns_topic.mongodb_alerts.arn
  protocol  = "email"
  endpoint  = var.ALERT_EMAIL  # Add this variable to variables.tf
}