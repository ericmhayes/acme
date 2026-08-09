# Module: service
# Responsibility: One load-balanced Fargate service (used for both the api and the
#   web app). Owns its task definition, a least-privilege task role and execution
#   role, a security group accepting traffic only from the ALB, its own target
#   group, a host-header rule attached to the shared ALB listener, a CloudWatch
#   log group, and injection of secrets via the task definition's secrets block.
#   A Datadog agent sidecar ships metrics/APM. Instantiated once per web-facing
#   service; no autoscaling is configured (fixed desired_count) — deliberately
#   right-sized for current volume.
#
# Implemented in Phase 3. Intentional stub defining the module boundary only.
