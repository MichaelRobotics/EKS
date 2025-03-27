# Create new file: module/CloudTrail/variables.tf

variable "PROJECT_NAME" {
  description = "Name of the project"
  type        = string
}

variable "SNS_TOPIC_ARN" {
  description = "ARN of the SNS topic for CloudTrail alerts"
  type        = string
}

variable "REGION" {
  description = "AWS region for resources"
  type        = string
}

# Add any other variables you need