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

output "conversation_history_table_name" {
  description = "Name of the Conversation History DynamoDB table."
  value       = module.conversation_history.table_name
}

output "conversation_history_table_arn" {
  description = "ARN of the Conversation History DynamoDB table."
  value       = module.conversation_history.table_arn
}

output "query_lambda_role_arn" {
  description = "ARN of the Query Lambda execution IAM role."
  value       = module.iam.query_lambda_role_arn
}

output "ingestion_lambda_role_arn" {
  description = "ARN of the Ingestion Lambda execution IAM role."
  value       = module.iam.ingestion_lambda_role_arn
}

output "opensearch_collection_name" {
  description = "Name of the OpenSearch Serverless vector collection."
  value       = module.opensearch.collection_name
}

output "opensearch_collection_arn" {
  description = "ARN of the OpenSearch Serverless vector collection."
  value       = module.opensearch.collection_arn
}

output "opensearch_collection_endpoint" {
  description = "HTTPS endpoint of the OpenSearch Serverless vector collection."
  value       = module.opensearch.collection_endpoint
}

output "bedrock_knowledge_base_id" {
  description = "ID of the Amazon Bedrock Knowledge Base."
  value       = module.bedrock.knowledge_base_id
}

output "bedrock_knowledge_base_arn" {
  description = "ARN of the Amazon Bedrock Knowledge Base."
  value       = module.bedrock.knowledge_base_arn
}

output "bedrock_knowledge_base_data_source_id" {
  description = "ID of the Bedrock Knowledge Base S3 data source."
  value       = module.bedrock.data_source_id
}

output "bedrock_knowledge_base_id_parameter_arn" {
  description = "ARN of the Bedrock Knowledge Base ID SSM parameter."
  value       = module.ssm_bedrock_kb_id.parameter_arn
}

output "ingestion_lambda_name" {
  description = "Name of the Ingestion Lambda function."
  value       = module.ingestion_lambda.lambda_name
}

output "ingestion_lambda_arn" {
  description = "ARN of the Ingestion Lambda function."
  value       = module.ingestion_lambda.lambda_arn
}

output "query_lambda_name" {
  description = "Name of the Query Lambda function."
  value       = module.query_lambda.lambda_name
}

output "query_lambda_arn" {
  description = "ARN of the Query Lambda function."
  value       = module.query_lambda.lambda_arn
}

output "query_lambda_invoke_arn" {
  description = "API Gateway invocation ARN of the Query Lambda function."
  value       = module.query_lambda.invoke_arn
}

output "api_id" {
  description = "ID of the created API Gateway HTTP API."
  value       = module.apigateway.api_id
}

output "api_arn" {
  description = "ARN of the created API Gateway HTTP API."
  value       = module.apigateway.api_arn
}

output "api_endpoint" {
  description = "Direct endpoint URL of the created API Gateway HTTP API."
  value       = module.apigateway.api_endpoint
}

output "api_gateway_invoke_url" {
  description = "Default stage invocation URL for the API Gateway HTTP API."
  value       = module.apigateway.invoke_url
}

output "chat_endpoint_url" {
  description = "Full URL for the POST /chat endpoint."
  value       = module.apigateway.chat_endpoint_url
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution hosting the frontend."
  value       = module.cloudfront.domain_name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution."
  value       = module.cloudfront.distribution_id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution."
  value       = module.cloudfront.distribution_arn
}

output "frontend_bucket_name" {
  description = "Name of the frontend S3 bucket."
  value       = module.frontend.bucket_name
}

output "sns_topic_arn" {
  description = "ARN of the alert SNS topic."
  value       = module.sns.topic_arn
}

output "cloudwatch_alarm_names" {
  description = "List of created CloudWatch alarm names."
  value       = module.cloudwatch.alarm_names
}

output "budget_name" {
  description = "Name of the created AWS budget."
  value       = module.budget.budget_name
}









