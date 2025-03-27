terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "learning-terraform-13452"
    key            = "backend/nginx-mongodb-cluster.tfstate"
    dynamodb_table = "dynamoDB-state-locking"
    encrypt        = true
    kms_key_id     = "alias/terraform-bucket-key"
  }
}

resource "aws_kms_key" "terraform_bucket_key" {
  description             = "This key is used to encrypt terraform state bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/terraform-bucket-key"
  target_key_id = aws_kms_key.terraform_bucket_key.key_id
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = "learning-terraform-13452"
  versioning_configuration {
    status = "Enabled"
  }
}