output "provider_api_key_secret_arn" {
  description = "ARN of the SMS/email provider API key secret."
  value       = aws_secretsmanager_secret.provider_api_key.arn
}

output "datadog_api_key_secret_arn" {
  description = "ARN of the Datadog API key secret."
  value       = aws_secretsmanager_secret.datadog_api_key.arn
}

output "datadog_app_key_secret_arn" {
  description = "ARN of the Datadog application key secret."
  value       = aws_secretsmanager_secret.datadog_app_key.arn
}
