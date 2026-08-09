# Acme Corp — Infrastructure

Infrastructure-as-code for Acme's appointment scheduling and reminder platform.
Acme runs a REST API, a clinic-facing web app, and a background reminder worker on
top of a PostgreSQL database, serving ~200 clinics today.

This repository gets Acme off the founder's hand-built VM and onto reproducible,
reviewable infrastructure sized for a 4-engineer team.

## What's here

| Path | Purpose |
|------|---------|
| `terraform/modules/` | Reusable building blocks (network, database, ECS services, worker pipeline, ALB, secrets, ECR, observability, CI OIDC) |
| `terraform/envs/{dev,staging,prod}/` | Per-environment root modules that compose the modules above |
| `.github/workflows/` | CI/CD: image build/deploy and Terraform plan/apply |
| `digger.yml` | Terraform plan-on-PR / apply-on-merge orchestration |
| `ARCHITECTURE.md` | The design, trade-offs, deployment flow, and migration plan |
| `EVOLUTION.md` | The next infrastructure investments and their triggers |
| `docs/` | Full AWS design doc and a design-only GCP alternative |

## Environments & accounts

Two AWS accounts: **non-prod** (hosts `dev` and `staging`, separated by VPC and IAM)
and **prod**. State lives in a per-environment S3 backend.

## Validating locally

No AWS credentials are required to validate:

```bash
cd terraform/envs/dev
terraform init -backend=false
terraform validate
```

Repeat for `envs/staging` and `envs/prod`.

## Conventions

- Terraform `>= 1.9`, AWS provider `~> 5.60` (pinned in each env's `versions.tf`).
- Placeholder values (account IDs, domains, ARNs) are deliberately fake:
  `123456789012`, `acme-example.com`, `REPLACE_ME`. Nothing here deploys as-is.
- `.terraform.lock.hcl` is committed; state files and `.terraform/` are not.
