resource "aws_cloudtrail" "mongodb_cloudtrail" {
  name                          = "${var.PROJECT_NAME}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  s3_key_prefix                 = "trail"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.cloudtrail_key.arn
  
  # Enable CloudWatch Logs integration
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail_logs.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_logs_role.arn
  
  # Track all event types
  event_selector {
    read_write_type           = "All"
    include_management_events = true
    
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3"]
    }
  }
  
  # Add insight selectors for unusual API activity detection
  insight_selector {
    insight_type = "ApiCallRateInsight"
  }
  
  tags = {
    Name        = "${var.PROJECT_NAME}-cloudtrail"
    Environment = "Production"
  }
}

# KMS key for encrypting CloudTrail logs
resource "aws_kms_key" "cloudtrail_key" {
  description             = "KMS key for CloudTrail logs encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudTrail to encrypt logs"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs to use key"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.REGION}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
      }
    ]
  })
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "${var.PROJECT_NAME}-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  
  # Removing prevent_destroy to allow destruction
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# S3 bucket policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_bucket.id}"
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_bucket.id}/trail/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "cloudtrail_bucket_versioning" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_encryption" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloudtrail_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "cloudtrail_public_access" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudWatch Log Group for CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail_logs" {
  name              = "/aws/cloudtrail/${var.PROJECT_NAME}"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.cloudtrail_key.arn
}

# IAM role for CloudTrail to CloudWatch Logs
resource "aws_iam_role" "cloudtrail_logs_role" {
  name = "${var.PROJECT_NAME}-cloudtrail-logs-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for CloudTrail logs
resource "aws_iam_policy" "cloudtrail_logs_policy" {
  name = "${var.PROJECT_NAME}-cloudtrail-logs-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail_logs.arn}:*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "cloudtrail_logs_attachment" {
  role       = aws_iam_role.cloudtrail_logs_role.name
  policy_arn = aws_iam_policy.cloudtrail_logs_policy.arn
}

data "aws_caller_identity" "current" {}

# CloudWatch alerts for suspicious activities
resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "${var.PROJECT_NAME}-unauthorized-api-calls"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnauthorizedAttemptCount"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "This alarm monitors for unauthorized API calls"
  alarm_actions       = [var.SNS_TOPIC_ARN]
  
  # Add dimensions if you created custom metrics
}

# Add to module/CloudTrail/main.tf

resource "aws_cloudwatch_log_metric_filter" "root_account_usage" {
  name           = "${var.PROJECT_NAME}-root-account-usage"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_logs.name
  
  metric_transformation {
    name      = "RootAccountUsage"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "${var.PROJECT_NAME}-unauthorized-api-calls"
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_logs.name
  
  metric_transformation {
    name      = "UnauthorizedAttemptCount"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "console_sign_in_without_mfa" {
  name           = "${var.PROJECT_NAME}-console-signin-without-mfa"
  pattern        = "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") }"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_logs.name
  
  metric_transformation {
    name      = "ConsoleSignInWithoutMFA"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

# Add alarms for the metrics
resource "aws_cloudwatch_metric_alarm" "root_account_usage_alarm" {
  alarm_name          = "${var.PROJECT_NAME}-root-account-usage-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "RootAccountUsage"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "This alarm monitors for root account usage"
  alarm_actions       = [var.SNS_TOPIC_ARN]
}

resource "aws_cloudwatch_metric_alarm" "console_signin_without_mfa_alarm" {
  alarm_name          = "${var.PROJECT_NAME}-console-signin-without-mfa-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ConsoleSignInWithoutMFA"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "This alarm monitors for console sign-ins without MFA"
  alarm_actions       = [var.SNS_TOPIC_ARN]
}