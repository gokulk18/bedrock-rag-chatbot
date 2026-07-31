# ==============================================================================
# Project Input Variables
# ==============================================================================
# Core variable declarations for the Amazon Bedrock RAG Chatbot infrastructure.
# Every variable includes a type, description, validation rule, and default value.
# ==============================================================================

variable "project_name" {
  type        = string
  description = "The project name used for resource naming prefixes and tags."
  default     = "bedrock-rag-chatbot"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name must contain only lowercase alphanumeric characters and hyphens."
  }
}

variable "environment" {
  type        = string
  description = "Target deployment environment (dev, staging, prod)."
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region where all infrastructure resources will be deployed."
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "aws_region must be a valid AWS region identifier (e.g., us-east-1)."
  }
}

variable "owner" {
  type        = string
  description = "Team or individual owner responsible for this infrastructure deployment."
  default     = "devops-team"

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner variable cannot be empty."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Additional key-value tags to append to all managed resources."
  default     = {}
}

variable "bedrock_model_id" {
  type        = string
  description = "Amazon Bedrock foundation model ID used for text generation."
  default     = "anthropic.claude-3-haiku-20240307-v1:0"

  validation {
    condition     = length(trimspace(var.bedrock_model_id)) > 0
    error_message = "bedrock_model_id cannot be empty."
  }
}

variable "alert_email" {
  type        = string
  description = "Email address to receive CloudWatch Alarms and AWS Budget notifications."
  default     = "admin@example.com"
}

variable "monthly_budget_limit" {
  type        = number
  description = "Monthly cost budget limit in USD."
  default     = 50
}

