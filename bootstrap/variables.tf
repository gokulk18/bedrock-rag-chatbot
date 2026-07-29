# ==============================================================================
# Input Variables
# ==============================================================================
# Input variable definitions with strong type constraints, validation rules,
# explicit descriptions, and sensible default values.
# ==============================================================================

variable "project_name" {
  type        = string
  description = "The project name used to scope resource naming and tagging conventions."
  default     = "bedrock-rag-chatbot"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name must contain only lowercase alphanumeric characters and hyphens."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment identifier (e.g., dev, staging, prod)."
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  type        = string
  description = "Target AWS Region where resources will be deployed."
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "aws_region must be a valid AWS region identifier (e.g., us-east-1)."
  }
}

variable "owner" {
  type        = string
  description = "Email or team designation responsible for managing this infrastructure."
  default     = "devops-team"

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner variable cannot be empty."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Additional key-value tags to apply to all resources provisioned by this module."
  default     = {}
}
