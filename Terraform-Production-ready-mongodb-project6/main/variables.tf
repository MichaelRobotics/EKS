
variable "PROJECT_NAME" {}
variable "CPU" {}
variable "AMI" {}
variable "MAX_SIZE" {}
variable "MIN_SIZE" {}
variable "DESIRED_CAP" {}
variable "PUB_SUB_1_A_CIDR" {}
variable "PUB_SUB_2_B_CIDR" {}
variable "PUB_SUB_3_C_CIDR" {}
variable "PRI_SUB_4_A_CIDR" {}
variable "PRI_SUB_5_B_CIDR" {}
variable "PRI_SUB_6_C_CIDR" {}
variable "PRI_SUB_7_A_CIDR" {}
variable "PRI_SUB_8_B_CIDR" {}
variable "PRI_SUB_9_C_CIDR" {}

variable "REGION" {
  description = "AWS region to deploy resources"
  type        = string

  validation {
    condition     = contains(["us-east-1", "us-west-1", "eu-west-1", "ap-southeast-1"], var.REGION)
    error_message = "The REGION must be a supported AWS region: us-east-1, us-west-1, eu-west-1, or ap-southeast-1."
  }
}

variable "VPC_CIDR" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.VPC_CIDR))
    error_message = "The VPC_CIDR must be a valid CIDR block."
  }
}