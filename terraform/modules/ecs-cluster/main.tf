# Module: ecs-cluster
# Responsibility: A single ECS cluster running Fargate, with Container Insights
#   enabled for metrics. The cluster is shared by the api, web, and worker
#   services; per-service task roles and definitions live in the service/worker
#   modules, not here.
#
# Implemented in Phase 3. Intentional stub defining the module boundary only.
