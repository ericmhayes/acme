# AWS Design (built architecture)

Deeper technical detail on the architecture defined in this repository. For the
overview, trade-offs, and deployment flow, start with
[ARCHITECTURE.md](../ARCHITECTURE.md).

## Accounts and environments

- **Two accounts.** `prod` (dedicated) and `non-prod` (shared by `dev` and
  `staging`, isolated by VPC and IAM). Prod is the hard PHI/blast-radius boundary.
- **Three environment roots** — `terraform/envs/{dev,staging,prod}` — each compose
  the shared modules in `terraform/modules/`. State is an S3 backend, one key per
  environment, with a DynamoDB lock table.
- **Single region**, `us-east-1`.
- Pinned Terraform (`>= 1.9, < 2.0`) and providers (AWS `~> 5.60`, Datadog
  `~> 3.40`).

## Network (`modules/network`)

- VPC per environment across two AZs, with public and private subnets in each.
- Public subnets host the ALB and NAT gateways; private subnets host all ECS
  tasks and RDS. Nothing with data touches a public subnet.
- **NAT gateways**: one in non-prod (cost), two in prod (one per AZ, for AZ-
  independent egress).
- **VPC endpoints**: an S3 gateway endpoint plus interface endpoints for
  `ecr.api`, `ecr.dkr`, `logs`, and `secretsmanager`. These let private tasks pull
  images, ship logs, and read secrets without routing that traffic through the NAT
  — cheaper and a tighter egress story.
- **VPC flow logs** to CloudWatch with extended retention, for audit.

## Data (`modules/database`, `modules/secrets`)

- **RDS PostgreSQL**, private, no public endpoint, `gp3` storage encrypted at
  rest, automated backups (7 days non-prod, 30 prod), Multi-AZ in prod,
  deletion protection in prod with a final snapshot.
- **Master credentials are RDS-managed** (`manage_master_user_password`) and live
  in Secrets Manager — never in Terraform state.
- **Secrets module** creates *containers only* for the SMS/email provider key and
  the Datadog API/app keys; values are set out-of-band, so no secret material is
  in state or git.

## Compute (`modules/ecs-cluster`, `modules/service`, `modules/worker`)

- One **ECS Fargate cluster** per environment with Container Insights.
- Tasks run on **ARM64/Graviton** for cost.
- **`service`** (instantiated for `api` and `web`): task definition, a
  least-privilege **task role** (starts empty) and a separate **execution role**
  (pulls images, reads only the secrets this service needs), a security group that
  accepts traffic only from the ALB, its own target group and host-header listener
  rule, a CloudWatch log group, a **Datadog agent sidecar**, and an ECS
  **deployment circuit breaker** that auto-rolls-back a failed deployment. Fixed
  `desired_count` — no reactive autoscaling; dev additionally runs a *scheduled*
  scale-to-zero outside working hours for cost.
- **`worker`**: an always-on Fargate service (no ALB) plus the reminder pipeline
  (below). Its task role is scoped to consuming exactly its own SQS queue; its
  execution role reads only its secrets.
- **Database access is via security groups, not IAM.** The `api` and `worker`
  security groups each add an ingress rule to the RDS security group from their own
  SG. This is done from the service side to avoid a database↔service dependency
  cycle.

## Reminder pipeline (the core design)

A **scheduled sweeper**, not per-appointment scheduled messages:

1. **EventBridge Scheduler** fires every minute (`rate(1 minute)`) and enqueues a
   "sweep" message to SQS via a role scoped to `sqs:SendMessage`.
2. The **worker** consumes the sweep, queries the database for appointments whose
   reminder is **due and not yet sent**, and enqueues per-reminder work.
3. A consumer sends each reminder through the third-party provider and records the
   send.

**Why a sweeper.** Appointments are rescheduled and cancelled constantly.
Per-appointment scheduled messages would require keeping a queue in sync with a
mutating calendar — every reschedule is a cancel-and-recreate, and drift means
either missed or duplicate reminders. Sweeping keeps the **database as the single
source of truth**; the schedule just says "look again."

**Idempotency.** A unique constraint on
`(appointment_id, reminder_type, target_send_at)` guarantees a given reminder is
recorded once even if the sweep overlaps or a message is redelivered. SQS
at-least-once delivery is therefore safe.

**Failure handling.** The main SQS queue has a **dead-letter queue** with a
redrive after 5 receives, so a poison message can't wedge the pipeline. If the
worker is down, nothing is lost — the next sweep re-queries the same due,
unsent rows.

## Ingress and edge (`modules/alb`)

- One internet-facing **ALB** shared by `api` and `web`, with an **ACM**
  certificate (DNS-validated), an **HTTP→HTTPS redirect**, a TLS 1.3 policy, and
  **host-based routing** (`api.` / `app.`).
- **AWS WAF** (regional WebACL) with three AWS managed rule groups
  (Common, KnownBadInputs, AmazonIpReputation) plus one rate-based rule on the
  booking path. Enabled in staging and prod; disabled in dev for cost.
- The ALB exports its listener ARN; each service owns its target group and
  listener rule, so the ALB and service modules don't form a cycle.

## Observability (`modules/observability`)

- Datadog resources as code. **Two SLOs**: booking API availability (99.9%) and
  reminder dispatch latency (99% within 15 minutes).
- **Exactly three P1 paging monitors** — reminder delivery failure, API
  availability SLO fast burn, and RDS unavailable/connection saturation — routed
  to PagerDuty. Paging is gated by `enable_paging` (prod only); lower environments
  route the same monitors to Slack so nothing pages off-hours for dev noise.
- **Non-paging monitors** (DLQ not empty, ECS CPU sustained, RDS free storage low)
  route to Slack by severity.
- **PHI scrubbing** in logs and APM is a required posture; no patient data in logs
  or traces.

## CI/CD and identity (`modules/ci-oidc`, `.github/`, `digger.yml`)

- **GitHub OIDC**, no long-lived keys. A read-only **plan role** (PRs) and a
  service-scoped **apply role** (merges). Both trust policies are conditioned on
  `repo:ericmhayes/acme:*`; the prod apply role additionally requires the
  `environment:prod` claim.
- **Digger** (backendless) runs plan-on-PR and apply-on-merge; prod apply is
  manual after review.
- **Infracost** posts cost deltas on PRs; **tflint + tfsec** run as a
  **non-blocking** advisory job.
- **Build & Deploy** builds/pushes images to ECR and rolls ECS services; prod is
  gated by the `prod` GitHub Environment.

## Security posture — done now

AWS BAA + HIPAA-eligible services; private database with no public endpoint;
encryption at rest and in transit; least-privilege per-service task roles (never a
shared broad role); CloudTrail with data events where PHI is accessed; extended
log retention; no PHI in logs/traces; no production data in lower environments;
no static credentials anywhere (OIDC only).

## Security posture — deferred (with triggers in EVOLUTION.md)

SOC 2, formal risk assessment, customer-managed KMS keys, egress firewall,
per-resource least-privilege apply IAM, and a workforce training program.
