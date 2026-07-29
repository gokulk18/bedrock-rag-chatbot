# ==============================================================================
# Terraform Versions and Provider Requirements
# ==============================================================================
# Specifies the required Terraform CLI version and provider requirements.
#
# HashiCorp & AWS Best Practices:
# - Always pin Terraform version and provider versions using minor or exact versions.
# - Use Terraform >= 1.15.0 to leverage native S3 state locking (use_lockfile).
# - Use AWS Provider ~> 6.56.0 for modern resource definitions and security defaults.
# ==============================================================================

terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.56.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}
