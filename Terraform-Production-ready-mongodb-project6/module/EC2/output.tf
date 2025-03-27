output "MONGOS_1_ID" {
  value = aws_instance.servers["mongos-1"].id
}
output "MONGOS_2_ID" {
  value = aws_instance.servers["mongos-2"].id
}

# In module/EC2/output.tf
output "SHARD_1_ARN" {
  value = aws_instance.servers["shard-1"].arn
}

output "SHARD_2_ARN" {
  value = aws_instance.servers["shard-2"].arn
}

output "SHARD_3_ARN" {
  value = aws_instance.servers["shard-3"].arn
}

# Continue for other instances