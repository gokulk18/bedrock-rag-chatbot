# ==============================================================================
# AWS Provider Configuration
# ==============================================================================
# Configures the AWS provider instance and applies default tags to all resources
# created by this Terraform configuration.
#
# AWS Best Practices:
# - Centralize region configuration via variables.
# - Apply mandatory default tags at provider level to enforce consistent tagging
#   across all managed infrastructure.
# ==============================================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.effective_tags
  }
}
