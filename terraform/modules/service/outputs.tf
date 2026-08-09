# Contract outputs for the service module. Wired to real resources in Phase 3.

output "service_name" {
  description = "Name of the ECS service."
  value       = null
}

output "task_definition_arn" {
  description = "ARN of the task definition."
  value       = null
}

output "target_group_arn" {
  description = "ARN of the service's ALB target group."
  value       = null
}

output "task_role_arn" {
  description = "ARN of the task role (least-privilege, per service)."
  value       = null
}

output "security_group_id" {
  description = "Security group attached to the service tasks."
  value       = null
}
