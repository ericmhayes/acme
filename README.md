# Acme Corp — Infrastructure

Infrastructure-as-code for Acme's appointment scheduling and reminder platform.
Acme runs a REST API, a clinic-facing web app, and a background reminder worker on
top of a PostgreSQL database, serving ~200 clinics today.

This repository gets Acme off the founder's hand-built VM and onto reproducible,
reviewable infrastructure sized for a 4-engineer team handling health-adjacent
data.

## Start here

| Document | What it covers |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | The design, diagrams, trade-offs, deliberate omissions, how the team deploys, migration/cutover, cost, and failure modes |
| [EVOLUTION.md](EVOLUTION.md) | The next investments, each with a concrete trigger, and where the design strains first |
| [docs/design-aws.md](docs/design-aws.md) | Deeper technical detail on the built AWS architecture |
| [docs/design-gcp.md](docs/design-gcp.md) | A design-only GCP equivalent (no code) |

## Repository layout

| Path | Purpose |
|------|---------|
| `terraform/modules/` | Reusable building blocks: `network`, `database`, `secrets`, `ecr`, `ecs-cluster`, `alb`, `service`, `worker`, `observability`, `ci-oidc` |
| `terraform/envs/{dev,staging,prod}/` | Per-environment root modules that compose the modules above |
| `.github/workflows/` | CI/CD: Terraform plan/apply (`terraform.yml`) and image build/deploy (`build-deploy.yml`) |
| `digger.yml` | Terraform plan-on-PR / apply-on-merge orchestration |
| `docs/img/` | Architecture diagrams (network topology and deployment flow) |

## Environments & accounts

Two AWS accounts: **non-prod** (hosts `dev` and `staging`, separated by VPC and
IAM) and **prod**. State lives in a per-environment S3 backend. Single region.

## Validating locally

No AWS or Datadog credentials are required to validate:

```bash
cd terraform/envs/dev
terraform init -backend=false
terraform validate
```

Repeat for `envs/staging` and `envs/prod`.

## Diagrams

Two diagrams, both embedded in [ARCHITECTURE.md](ARCHITECTURE.md):

- `docs/img/architecture.png` — **network topology** (accounts, VPCs, subnets, AZs)
- `docs/img/deploy-flow.png` — **deployment flow** (infrastructure and application
  change paths)

## Conventions

- Terraform `>= 1.9`, AWS provider `~> 5.60`, Datadog provider `~> 3.40` (pinned
  per environment).
- Placeholder values are deliberately fake: `123456789012` / `210987654321`
  (account IDs), `acme-example.com`, `REPLACE_ME`. Nothing here deploys as-is.
- `.terraform.lock.hcl` is committed; state files and `.terraform/` are not.
