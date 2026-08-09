# Contract outputs for the database module. Wired to real resources in Phase 2.

output "db_instance_arn" {
  description = "ARN of the RDS instance."
  value       = null
}

output "db_endpoint" {
  description = "Connection endpoint (host:port) of the RDS instance."
  value       = null
}

output "db_port" {
  description = "Port the database listens on."
  value       = null
}

output "db_security_group_id" {
  description = "Security group protecting the database."
  value       = null
}

output "master_user_secret_arn" {
  description = "ARN of the RDS-managed master credentials secret in Secrets Manager."
  value       = null
}
