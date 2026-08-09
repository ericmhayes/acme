# Contract outputs for the secrets module. Wired to real resources in Phase 2.

output "provider_api_key_secret_arn" {
  description = "ARN of the SMS/email provider API key secret."
  value       = null
}

output "datadog_api_key_secret_arn" {
  description = "ARN of the Datadog API key secret."
  value       = null
}

output "datadog_app_key_secret_arn" {
  description = "ARN of the Datadog application key secret."
  value       = null
}
