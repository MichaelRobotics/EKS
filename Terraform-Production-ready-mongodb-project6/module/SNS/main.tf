# SNS Topic for notifications
resource "aws_sns_topic" "notifications" {
  name = "${var.PROJECT_NAME}-notifications"
  
  tags = {
    Name = "${var.PROJECT_NAME}-notifications"
  }
} 