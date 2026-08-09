# Module: ecr
# Responsibility: One ECR repository per container image (api, web, worker) with
#   scan-on-push enabled and a lifecycle policy that expires untagged images and
#   caps retained image count to keep storage bounded.
#
# Implemented in Phase 2. Intentional stub defining the module boundary only.
