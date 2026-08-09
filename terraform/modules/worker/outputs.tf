# Contract outputs for the worker module. Values are wired when the module is implemented.

output "service_name" {
  description = "Name of the worker ECS service."
  value       = null
}

output "queue_url" {
  description = "URL of the main SQS queue."
  value       = null
}

output "queue_arn" {
  description = "ARN of the main SQS queue."
  value       = null
}

output "dlq_arn" {
  description = "ARN of the dead-letter queue."
  value       = null
}

output "task_role_arn" {
  description = "ARN of the worker task role (least-privilege)."
  value       = null
}
