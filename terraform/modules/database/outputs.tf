output "db_instance_arn" {
  description = "ARN of the RDS instance."
  value       = aws_db_instance.this.arn
}

output "db_endpoint" {
  description = "Connection endpoint (host:port) of the RDS instance."
  value       = aws_db_instance.this.endpoint
}

output "db_port" {
  description = "Port the database listens on."
  value       = aws_db_instance.this.port
}

output "db_security_group_id" {
  description = "Security group protecting the database."
  value       = aws_security_group.db.id
}

output "master_user_secret_arn" {
  description = "ARN of the RDS-managed master credentials secret in Secrets Manager."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
