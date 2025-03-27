terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region  = var.REGION
  # Removing the profile configuration to use default credentials
  # profile = "myTerraform"
}