# Create new file: module/CloudTrail/output.tf

output "cloudtrail_id" {
  value = aws_cloudtrail.mongodb_cloudtrail.id
}

output "cloudtrail_arn" {
  value = aws_cloudtrail.mongodb_cloudtrail.arn
}

output "cloudtrail_s3_bucket_name" {
  value = aws_s3_bucket.cloudtrail_bucket.id
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.cloudtrail_logs.name
}