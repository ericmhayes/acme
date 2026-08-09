# Module: alb
# Responsibility: A single internet-facing Application Load Balancer shared by the
#   api and web services, with an HTTPS listener terminating an ACM certificate,
#   an HTTP->HTTPS redirect, and host-based routing (api.* vs app.*). A regional
#   AWS WAF WebACL using AWS managed rule groups is associated with the ALB. The
#   listener is exported so each service can attach its own target group and
#   host-header rule; the ALB does not own the target groups.
#
# Implemented in Phase 3. Intentional stub defining the module boundary only.
