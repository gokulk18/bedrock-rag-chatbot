# ==============================================================================
# Root Module Outputs
# ==============================================================================
# Exports key attributes of the infrastructure resources provisioned in this project.
# ==============================================================================

output "documents_bucket_id" {
  description = "ID of the Knowledge Base documents S3 bucket."
  value       = module.documents.bucket_id
}

output "documents_bucket_name" {
  description = "Name of the Knowledge Base documents S3 bucket."
  value       = module.documents.bucket_name
}

output "documents_bucket_arn" {
  description = "ARN of the Knowledge Base documents S3 bucket."
  value       = module.documents.bucket_arn
}

output "bedrock_model_id_parameter_name" {
  description = "Name of the Bedrock model ID SSM parameter."
  value       = module.ssm_bedrock_model_id.parameter_name
}

output "bedrock_model_id_parameter_arn" {
  description = "ARN of the Bedrock model ID SSM parameter."
  value       = module.ssm_bedrock_model_id.parameter_arn
}
