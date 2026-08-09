# Contract outputs for the alb module. Wired to real resources in Phase 3.

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = null
}

output "alb_dns_name" {
  description = "DNS name of the ALB (for Route 53 alias records)."
  value       = null
}

output "alb_zone_id" {
  description = "Hosted zone ID of the ALB (for Route 53 alias records)."
  value       = null
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener; services attach host-header rules to it."
  value       = null
}

output "alb_security_group_id" {
  description = "Security group attached to the ALB; services allow ingress from it."
  value       = null
}
