# ==============================================================================
# Local Values & Naming Conventions
# ==============================================================================
# Centralizes standard resource naming rules, prefixes, and mandatory tagging
# applied across all modules and resources in this project.
# ==============================================================================

locals {
  # Standardized prefix used for resource naming across all AWS services
  name_prefix = "${var.project_name}-${var.environment}"

  # Merged tag dictionary passed directly to the AWS provider default_tags block
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
      ManagedBy   = "Terraform"
    },
    var.common_tags
  )
}
