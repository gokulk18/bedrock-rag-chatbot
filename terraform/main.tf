# ==============================================================================
# Amazon Bedrock RAG Chatbot - Main Composition Root
# ==============================================================================
# Phase 3: Instantiates the reusable S3 module for Knowledge Base Documents.
# Phase 4: Instantiates the reusable SSM module for Bedrock Model ID parameter.
# ==============================================================================

# Data lookup for current AWS account ID (used for globally unique bucket naming)
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# Knowledge Base Documents Bucket
# ------------------------------------------------------------------------------
# Stores source documents (PDFs, TXT, MD) ingested by Amazon Bedrock Knowledge Base.
module "documents" {
  source = "./modules/s3"

  bucket_name       = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-documents"
  enable_versioning = true
  enable_encryption = true

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# Bedrock Model ID SSM Parameter
# ------------------------------------------------------------------------------
# Stores the Amazon Bedrock foundation model ID centrally in SSM Parameter Store.
module "ssm_bedrock_model_id" {
  source = "./modules/ssm"

  parameter_name        = "/${local.name_prefix}/bedrock/model-id"
  parameter_value       = var.bedrock_model_id
  parameter_description = "Amazon Bedrock foundation model ID for RAG Chatbot text generation."
  parameter_type        = "String"
  overwrite             = true

  tags = local.common_tags
}
