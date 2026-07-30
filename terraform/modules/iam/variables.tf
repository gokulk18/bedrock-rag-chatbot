# ==============================================================================
# IAM Module Input Variables
# ==============================================================================

variable "name_prefix" {
  type        = string
  description = "Standardized naming prefix for IAM roles and policies."
}

variable "documents_bucket_arn" {
  type        = string
  description = "ARN of the Knowledge Base documents S3 bucket."
}

variable "dynamodb_table_arn" {
  type        = string
  description = "ARN of the Conversation History DynamoDB table."
}

variable "ssm_parameter_arn" {
  type        = string
  description = "ARN of the Bedrock Model ID SSM parameter."
}

variable "opensearch_collection_arn" {
  type        = string
  description = "ARN of the OpenSearch Serverless vector collection."
  default     = "*"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to apply to IAM resources."
  default     = {}
}

