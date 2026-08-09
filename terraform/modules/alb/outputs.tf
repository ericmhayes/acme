output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB (for Route 53 alias records)."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the ALB (for Route 53 alias records)."
  value       = aws_lb.this.zone_id
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener; services attach host-header rules to it."
  value       = aws_lb_listener.https.arn
}

output "alb_security_group_id" {
  description = "Security group attached to the ALB; services allow ingress from it."
  value       = aws_security_group.alb.id
}
