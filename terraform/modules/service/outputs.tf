output "service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "ARN of the task definition."
  value       = aws_ecs_task_definition.this.arn
}

output "target_group_arn" {
  description = "ARN of the service's ALB target group."
  value       = aws_lb_target_group.this.arn
}

output "task_role_arn" {
  description = "ARN of the task role (least-privilege, per service)."
  value       = aws_iam_role.task.arn
}

output "security_group_id" {
  description = "Security group attached to the service tasks."
  value       = aws_security_group.service.id
}
