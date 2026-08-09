# Module: observability
# Responsibility: Datadog monitors and SLOs defined as code. Exactly three P1
#   paging monitors (reminder delivery failure, API availability SLO fast burn,
#   RDS unavailable/connection saturation) routed to PagerDuty; a small set of
#   non-paging monitors routed to Slack by severity. Two SLOs: booking API
#   availability (99.9%) and reminder dispatch latency (99% within 15 minutes).
#   This module owns Datadog resources only; it does not create the CloudWatch
#   substrate, which the AWS resources emit natively.
#
# Implemented in Phase 3. Intentional stub defining the module boundary only.
