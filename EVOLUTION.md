# Evolution

The next investments, in order, each tied to a concrete trigger rather than a
calendar. The rule: don't build it until the signal fires. Everything here was
deliberately left out of the initial build (see
[ARCHITECTURE.md](ARCHITECTURE.md#3-what-was-deliberately-left-out-or-kept-simple-and-why)).

## The next investments, in priority order

### 1. SOC 2 Type II + a formal risk assessment

**When** the first enterprise or multi-clinic customer's procurement sends a
security questionnaire or asks for a SOC 2 report — or when preparing the Series A
raise, whichever comes first — **we need** to begin SOC 2 Type II and a documented
risk assessment.

This is first because it's the item most likely to gate revenue given the
health-adjacent, trust-based sales motion, and it's organizational as much as
technical: policies, access reviews, vendor management, and evidence collection.
Much of the infrastructure posture (least-privilege roles, encryption, audit
logging, no PHI in lower environments) is already aligned; the gap is process and
attestation. It also pulls in two sub-items below (CMK, tighter IAM).

### 2. RDS Proxy (connection pooling)

**When** Postgres connection count trends toward the instance's `max_connections`
as task counts grow — concretely, when the **"RDS unavailable or connections
saturated" P1 monitor** starts firing on connection count rather than availability
— **we need** RDS Proxy in front of the database.

This is the first strain that comes from the compute model itself: more Fargate
tasks means more direct connections. RDS Proxy is cheap, drop-in, and empirically
triggered by an alert we already have — the right kind of just-in-time fix.

### 3. Tighter, per-resource apply IAM (least privilege)

**When** we start SOC 2 (item 1) or when the team grows past ~6 engineers and more
people can trigger applies — **we need** to replace the service-scoped Terraform
apply policy with per-resource least privilege and a permissions boundary.

Today the apply role is scoped to the services this stack manages, which is honest
but broad. Narrowing it is deferred deliberately: hand-tuning least-privilege
policies is high-effort and low-value until either an auditor or a larger team
raises the blast-radius stakes.

### 4. PR / ephemeral preview environments

**When** the team grows past ~6–8 engineers and shared-staging contention starts
blocking merges (two people can't validate on staging at once) — **we need**
ephemeral per-PR environments.

The design intentionally skips this at four engineers. The trigger is a
team-size and workflow-friction signal, not a technical limit.

### 5. Customer-managed KMS keys + egress control

**When** a customer contract, BAA amendment, or auditor explicitly requires key
custody or demonstrable egress restriction — **we need** customer-managed KMS keys
for RDS/Secrets/logs and an egress control (AWS Network Firewall or equivalent).

Grouped because both are contract/auditor-driven hardening, not day-one needs.
AWS-managed encryption already covers encryption-at-rest; this is about *who holds
the keys* and *proving* egress is constrained.

### 6. Read replica + a separate reporting/analytics path

**When** clinic-facing reporting or internal analytics queries begin contending
with booking writes on the primary (slow-query alerts, or a reporting feature that
runs heavy aggregations) — **we need** a read replica and a dedicated reporting
path, and eventually a lightweight warehouse.

This is the first data-layer strain as customers 3x. A read replica is the minimal
answer; it deliberately precedes anything like sharding or a full data warehouse,
which are far-future and explicitly out of scope now.

## Where the architecture strains first as Acme grows

Honest self-critique — the pressure points in *this* design, roughly in the order
they'd bite:

- **The single reminder worker and the 1-minute sweep.** The first throughput
  ceiling. Fine at 3 bookings/minute, but as volume climbs the sweep query and a
  single consumer are where you'd feel it first. Mitigations before a rewrite:
  widen worker count, shorten/lengthen the interval, add a queue-depth alert.
- **The shared ALB and single ECS cluster.** Fine now; the point where multi-team
  ownership or noisy-neighbor isolation would justify splitting clusters or load
  balancers.
- **Single region.** The deliberate availability ceiling. A compliance requirement
  or a contractual uptime SLA is what would force multi-region — otherwise it stays
  out.
- **The two-account model.** Dev and staging share an account. Org growth or a
  blast-radius concern is what would justify the third account we rejected now.
- **Broad apply IAM.** Convenient today; the first thing a security review flags
  (covered by item 3).
