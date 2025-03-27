resource "aws_backup_vault" "mongodb_backup_vault" {
  name = "${var.PROJECT_NAME}-backup-vault"
}

resource "aws_backup_plan" "mongodb_backup_plan" {
  name = "${var.PROJECT_NAME}-backup-plan"

  rule {
    rule_name         = "DailyBackups"
    target_vault_name = aws_backup_vault.mongodb_backup_vault.name
    schedule          = "cron(0 5 * * ? *)"  # 5 AM UTC daily
    
    lifecycle {
      delete_after = 30  # Keep backups for 30 days
    }
  }
  
  rule {
    rule_name         = "WeeklyBackups"
    target_vault_name = aws_backup_vault.mongodb_backup_vault.name
    schedule          = "cron(0 0 ? * SUN *)"  # Midnight UTC on Sundays
    
    lifecycle {
      delete_after = 90  # Keep weekly backups for 90 days
    }
  }
}

resource "aws_backup_selection" "mongodb_backup_selection" {
  name          = "${var.PROJECT_NAME}-backup-selection"
  iam_role_arn  = aws_iam_role.backup_role.arn
  plan_id       = aws_backup_plan.mongodb_backup_plan.id
  
  resources = [
    aws_instance.servers["shard-1"].arn,
    aws_instance.servers["shard-2"].arn,
    aws_instance.servers["shard-3"].arn,
    # Add all your MongoDB instances
  ]
}

resource "aws_iam_role" "backup_role" {
  name = "${var.PROJECT_NAME}-backup-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}