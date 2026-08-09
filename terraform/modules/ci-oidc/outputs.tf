output "oidc_provider_arn" {
  description = "ARN of the GitHub Actions IAM OIDC provider."
  value       = local.provider_arn
}

output "plan_role_arn" {
  description = "ARN of the read-only Terraform plan role assumed on pull requests."
  value       = aws_iam_role.plan.arn
}

output "apply_role_arn" {
  description = "ARN of the Terraform apply role assumed on merge (gated in prod)."
  value       = aws_iam_role.apply.arn
}
