# ==============================================================================
# AWS Provider Configuration
# ==============================================================================
# Configures the AWS provider instance and sets default tags across all resources
# managed by this project.
#
# Best Practices:
# - Region defined via var.aws_region
# - Applies default_tags at the provider level using local.common_tags
# ==============================================================================

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
