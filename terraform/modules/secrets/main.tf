# Module: secrets
# Responsibility: Secrets Manager secret containers for the third-party SMS/email
#   provider API key and the Datadog API/app keys. Only the container is created
#   here; the actual secret values are set out-of-band (console/CLI) so no secret
#   material ever lands in Terraform state or git history. Database master
#   credentials are NOT created here — they are managed by the database module
#   via RDS-managed passwords.
#
# Implemented in Phase 2. Intentional stub defining the module boundary only.
