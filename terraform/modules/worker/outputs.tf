output "service_name" {
  description = "Name of the worker ECS service."
  value       = aws_ecs_service.this.name
}

output "queue_url" {
  description = "URL of the main SQS queue."
  value       = aws_sqs_queue.main.url
}

output "queue_arn" {
  description = "ARN of the main SQS queue."
  value       = aws_sqs_queue.main.arn
}

output "dlq_arn" {
  description = "ARN of the dead-letter queue."
  value       = aws_sqs_queue.dlq.arn
}

output "task_role_arn" {
  description = "ARN of the worker task role (least-privilege)."
  value       = aws_iam_role.task.arn
}
