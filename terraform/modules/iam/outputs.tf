
output "query_lambda_role_arn" {
  description = "ARN of the Query Lambda execution IAM role."
  value       = aws_iam_role.query_lambda.arn
}

output "query_lambda_role_name" {
  description = "Name of the Query Lambda execution IAM role."
  value       = aws_iam_role.query_lambda.name
}

output "ingestion_lambda_role_arn" {
  description = "ARN of the Ingestion Lambda execution IAM role."
  value       = aws_iam_role.ingestion_lambda.arn
}

output "ingestion_lambda_role_name" {
  description = "Name of the Ingestion Lambda execution IAM role."
  value       = aws_iam_role.ingestion_lambda.name
}

output "bedrock_kb_role_arn" {
  description = "ARN of the Amazon Bedrock Knowledge Base service execution IAM role."
  value       = aws_iam_role.bedrock_kb.arn
}

output "bedrock_kb_role_name" {
  description = "Name of the Amazon Bedrock Knowledge Base service execution IAM role."
  value       = aws_iam_role.bedrock_kb.name
}

