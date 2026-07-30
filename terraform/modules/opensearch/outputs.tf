# ==============================================================================
# OpenSearch Serverless Module Outputs
# ==============================================================================

output "collection_name" {
  description = "Name of the created OpenSearch Serverless collection."
  value       = aws_opensearchserverless_collection.this.name
}

output "collection_id" {
  description = "ID of the created OpenSearch Serverless collection."
  value       = aws_opensearchserverless_collection.this.id
}

output "collection_arn" {
  description = "ARN of the created OpenSearch Serverless collection."
  value       = aws_opensearchserverless_collection.this.arn
}

output "collection_endpoint" {
  description = "HTTPS endpoint of the created OpenSearch Serverless collection."
  value       = aws_opensearchserverless_collection.this.collection_endpoint
}
