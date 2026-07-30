# ==============================================================================
# Bedrock Module Input Variables
# ==============================================================================

variable "knowledge_base_name" {
  type        = string
  description = "Name of the Amazon Bedrock Knowledge Base."
}

variable "role_arn" {
  type        = string
  description = "IAM role ARN assumed by Bedrock service to access S3 and OpenSearch."
}

variable "collection_arn" {
  type        = string
  description = "ARN of the OpenSearch Serverless vector collection."
}

variable "vector_index_name" {
  type        = string
  description = "Name of the vector index inside the OpenSearch Serverless collection."
  default     = "bedrock-knowledge-base-default-index"
}

variable "documents_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket containing source documents."
}

variable "embedding_model_arn" {
  type        = string
  description = "ARN of the Bedrock text embedding model (e.g., Titan Text Embeddings V2)."
}

variable "data_source_name" {
  type        = string
  description = "Name of the Bedrock Knowledge Base S3 data source."
  default     = "s3-documents-data-source"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to apply to the Bedrock Knowledge Base."
  default     = {}
}
