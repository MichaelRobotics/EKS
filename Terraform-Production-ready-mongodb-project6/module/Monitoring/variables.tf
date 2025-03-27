variable "PROJECT_NAME" {
  description = "Name of the project"
  type        = string
}

variable "REGION" {
  description = "AWS region for resources"
  type        = string
}

variable "VPC_ID" {
  description = "ID of the VPC"
  type        = string
}

variable "MONGOS_1_ID" {
  description = "ID of the first MongoDB router instance"
  type        = string
}

variable "MONGOS_2_ID" {
  description = "ID of the second MongoDB router instance"
  type        = string
}

variable "ALERT_EMAIL" {
  description = "Email address for monitoring alerts"
  type        = string
  default     = "admin@example.com"
}
