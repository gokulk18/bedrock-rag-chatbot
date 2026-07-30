# ==============================================================================
# Bedrock Module Outputs
# ==============================================================================

output "knowledge_base_id" {
  description = "ID of the created Amazon Bedrock Knowledge Base."
  value       = aws_bedrockagent_knowledge_base.this.id
}

output "knowledge_base_arn" {
  description = "ARN of the created Amazon Bedrock Knowledge Base."
  value       = aws_bedrockagent_knowledge_base.this.arn
}

output "knowledge_base_name" {
  description = "Name of the created Amazon Bedrock Knowledge Base."
  value       = aws_bedrockagent_knowledge_base.this.name
}

output "data_source_id" {
  description = "ID of the created Bedrock Knowledge Base S3 data source."
  value       = aws_bedrockagent_data_source.this.data_source_id
}
