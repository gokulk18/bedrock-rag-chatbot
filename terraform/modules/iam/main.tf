variable "name_prefix" { type = string }
variable "documents_bucket_arn" { type = string }
variable "vector_index_arn" { type = string }
variable "embedding_model_arn" { type = string }
variable "generation_model_arn" { type = string }
variable "knowledge_base_arn" { type = string }
variable "conversations_table_arn" { type = string }

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "bedrock_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "bedrock_kb" {
  name               = "${var.name_prefix}-bedrock-kb"
  assume_role_policy = data.aws_iam_policy_document.bedrock_assume.json
}
resource "aws_iam_role_policy" "bedrock_kb" {
  role = aws_iam_role.bedrock_kb.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["bedrock:InvokeModel"], Resource = var.embedding_model_arn },
    { Effect = "Allow", Action = ["s3:GetObject", "s3:ListBucket"], Resource = [var.documents_bucket_arn, "${var.documents_bucket_arn}/*"] },
    { Effect = "Allow", Action = ["s3vectors:PutVectors", "s3vectors:GetVectors", "s3vectors:DeleteVectors", "s3vectors:QueryVectors", "s3vectors:GetIndex"], Resource = var.vector_index_arn }
  ] })
}
resource "aws_iam_role" "query" {
  name               = "${var.name_prefix}-query"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}
resource "aws_iam_role" "ingestion" {
  name               = "${var.name_prefix}-ingestion"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}
resource "aws_iam_role_policy_attachment" "query_logs" {
  role       = aws_iam_role.query.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "ingestion_logs" {
  role       = aws_iam_role.ingestion.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy" "query" {
  role = aws_iam_role.query.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["bedrock:RetrieveAndGenerate"], Resource = "*" },
    { Effect = "Allow", Action = ["bedrock:InvokeModel"], Resource = var.generation_model_arn },
    { Effect = "Allow", Action = ["dynamodb:PutItem", "dynamodb:Query"], Resource = var.conversations_table_arn }
  ] })
}
resource "aws_iam_role_policy" "ingestion" {
  role = aws_iam_role.ingestion.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["bedrock:StartIngestionJob", "bedrock:GetIngestionJob"], Resource = var.knowledge_base_arn }
  ] })
}
output "bedrock_kb_role_arn" { value = aws_iam_role.bedrock_kb.arn }
output "query_lambda_role_arn" { value = aws_iam_role.query.arn }
output "ingestion_lambda_role_arn" { value = aws_iam_role.ingestion.arn }
