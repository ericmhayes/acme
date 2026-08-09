# Module: ecs-cluster
# Responsibility: A single ECS cluster running Fargate, with Container Insights
#   enabled for metrics. The cluster is shared by the api, web, and worker
#   services; per-service task roles and definitions live in the service/worker
#   modules, not here.
#
# TODO: implement. This file currently declares the module boundary only
# (see variables.tf and outputs.tf for the interface).
