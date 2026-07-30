# ==============================================================================
# Terraform CLI & Provider Version Requirements
# ==============================================================================
# Pins the required Terraform CLI version and AWS Provider version.
#
# Standards:
# - Required Terraform CLI: >= 1.15.0 (enables native S3 lockfile support)
# - AWS Provider: ~> 6.56.0
# ==============================================================================

terraform {
  required_version = ">= 1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.54.0"
    }
  }
}
