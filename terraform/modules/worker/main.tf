# Module: worker
# Responsibility: The reminder pipeline. An always-on Fargate service (no ALB)
#   that consumes an SQS queue; an EventBridge Scheduler that fires on an interval
#   (rate(1 minute)) to enqueue a sweep message; an SQS main queue plus a
#   dead-letter queue with a redrive policy; and a least-privilege task role
#   scoped to exactly this queue, the database, and the provider API key secret.
#   The sweeper queries appointments whose reminder is due and not yet sent, so
#   the database stays the single source of truth. A Datadog agent sidecar ships
#   metrics/APM.
#
# Implemented in Phase 3. Intentional stub defining the module boundary only.
