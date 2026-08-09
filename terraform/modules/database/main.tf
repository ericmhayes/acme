# Module: database
# Responsibility: A single RDS PostgreSQL instance in private subnets with no
#   public endpoint, Multi-AZ toggled by var.multi_az (on in prod), storage
#   encryption at rest, automated backups, deletion protection in prod, and a
#   dedicated security group that only accepts connections from the app tasks.
#   Master credentials are managed by RDS in Secrets Manager
#   (manage_master_user_password), so no password is ever written to state.
#
# Implemented in Phase 2. Intentional stub defining the module boundary only.
