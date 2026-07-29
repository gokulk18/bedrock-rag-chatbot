variable "aws_region" {
  description = "AWS Region in which to deploy the application."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short, globally unique-safe project prefix."
  type        = string
  default     = "bedrock-rag-chatbot"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "bedrock_model_id" {
  description = "Generation model used by RetrieveAndGenerate."
  type        = string
  default     = "amazon.nova-micro-v1:0"
}

variable "budget_limit_usd" {
  description = "Monthly cost budget in USD."
  type        = number
  default     = 10
}

variable "budget_alert_email" {
  description = "Optional email address for budget alerts. Leave empty to disable email subscriptions."
  type        = string
  default     = ""
}
