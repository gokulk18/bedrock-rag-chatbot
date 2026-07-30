variable "project_name" {
  description = "Project name used for bucket naming and tagging."
  type        = string
  default     = "bedrock-rag-chatbot"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment for the bootstrap resources."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region where the backend bucket will be created."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "aws_region must use a valid AWS region format such as us-east-1."
  }
}

variable "owner" {
  description = "Owner or team responsible for the bootstrap resources."
  type        = string
  default     = "devops-team"

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner cannot be empty."
  }
}

variable "common_tags" {
  description = "Optional additional tags to apply to the backend resources."
  type        = map(string)
  default     = {}
}
