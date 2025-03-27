variable "PROJECT_NAME" {
  description = "Name of the project"
  type        = string
}

variable "REGION" {
  description = "AWS region for resources"
  type        = string
}

variable "INSTANCE_ARNS" {
  description = "List of ARNs of instances to backup"
  type        = list(string)
}
