# GCP Design (alternative — design only, no code)

This is a design-only counterpart to the built AWS architecture, mapping each
decision to its GCP-idiomatic equivalent. There is no Terraform for it in this
repo; it exists to show the design would port cleanly, and where GCP is actually
simpler or adds a moving part.

The same constraints apply — ~200 clinics, ~40k patients/month, ~1–3 bookings/
minute, 4 engineers, health-adjacent data, single region. The reasoning behind
each choice is identical to the AWS design; only the primitives change.

## Service-by-service mapping

| Concern | AWS (built) | GCP (this design) | Notes |
|---|---|---|---|
| API / web compute | ECS Fargate services | **Cloud Run services** | Simpler: no cluster, task defs, or target-group wiring; scales to zero in lower envs |
| Worker | Always-on Fargate service | **Cloud Run service** (min-instances ≥ 1) | Stays warm to consume the queue |
| Database | RDS PostgreSQL Multi-AZ | **Cloud SQL for PostgreSQL**, regional HA | One-flag HA, managed backups, private IP |
| Ingress / TLS | ALB + ACM | **Global External HTTPS Load Balancer** + Google-managed cert | Managed certs remove ACM/DNS validation steps |
| WAF | AWS WAF managed rules | **Cloud Armor** (preconfigured WAF rules) | Direct equivalent |
| Reminder schedule | EventBridge Scheduler | **Cloud Scheduler** | Cron/interval trigger |
| Reminder queue | SQS + DLQ | **Pub/Sub** topic + subscription + **dead-letter topic** | Same at-least-once semantics; idempotency constraint unchanged |
| Secrets | Secrets Manager | **Secret Manager** | Near-identical |
| Images | ECR | **Artifact Registry** | Near-identical |
| Private egress to managed APIs | VPC endpoints | **Private Google Access** / VPC connector | Cloud Run reaches Cloud SQL via **Serverless VPC Access connector** (an added piece) |
| Observability | Datadog (CloudWatch substrate) | **Datadog** (Cloud Monitoring substrate) | Keep Datadog for parity; SLOs/monitors identical |
| CI → cloud identity | GitHub OIDC → IAM roles | GitHub OIDC → **Workload Identity Federation** | Same "no static keys" story; WIF binds to a service account |
| IaC | Terraform + S3/DynamoDB state | Terraform + **GCS** state bucket | Same tooling and Digger flow |

## Accounts and environment isolation

GCP's isolation unit is the **project**, not the account. The two-account model
maps to:

- A **prod project** (hard boundary), and a **non-prod project** hosting dev and
  staging separated by VPC and IAM — mirroring the AWS split.
- All under an **organization** with folders, so org policy (e.g. "no public IPs
  on Cloud SQL") is enforced centrally — something that's more work to achieve on
  AWS.

## Reminder pipeline on GCP

Identical design, different primitives: **Cloud Scheduler** fires every minute
and publishes a sweep message to a **Pub/Sub** topic; the worker (Cloud Run)
subscribes, queries Cloud SQL for due-and-unsent reminders, and publishes
per-reminder work; a subscription delivers to the sender. A **dead-letter topic**
plays the SQS DLQ role. The same
`(appointment_id, reminder_type, target_send_at)` unique constraint provides
idempotency. The database stays the single source of truth — the rationale does
not change.

## Where GCP is simpler

- **Cloud Run** removes the ECS control surface (clusters, task definitions,
  target groups, desired counts). For three stateless services this is materially
  less to own, and scale-to-zero cuts non-prod cost.
- **Google-managed SSL certificates** remove the ACM issuance/validation dance.
- **Org policies** give centrally-enforced guardrails (no public DB, required
  CMEK, allowed regions) that on AWS require SCPs plus extra config.

## Where GCP adds a moving part

- **Serverless VPC Access connector.** Cloud Run is serverless but the database is
  on a private VPC, so reaching Cloud SQL's private IP needs a connector — an
  extra component AWS's in-VPC Fargate tasks don't require.
- **Global load balancer complexity.** GCP's HTTPS LB is powerful but has more
  pieces (backend services, NEGs, URL maps) than an ALB for a simple two-host
  routing case.

## Why we submitted AWS

The built solution is AWS because it can be defended end-to-end here. This GCP
design shows the architecture is not AWS-specific: every decision (managed
Postgres with HA, serverless containers, a scheduled DB-driven sweeper, managed
secrets, OIDC-federated CI, Datadog for SLOs) has a clean GCP equivalent, and the
right-sizing judgment — no Kubernetes, no multi-region, no autoscaling, two
environments' worth of isolation — is identical on either cloud.
