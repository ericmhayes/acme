# Module: ci-oidc
# Responsibility: The GitHub Actions -> AWS trust path. An IAM OIDC provider for
#   token.actions.githubusercontent.com and two roles: a read-only plan role and
#   a broader apply role. Both trust policies are conditioned on the specific
#   repository (repo:ericmhayes/acme:*); the prod apply role is further narrowed
#   to the GitHub "prod" environment claim so it can only be assumed from an
#   approved deployment. No long-lived access keys exist anywhere.
#
# TODO: implement. This file currently declares the module boundary only
# (see variables.tf and outputs.tf for the interface).
