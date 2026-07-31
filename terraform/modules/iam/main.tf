# ==============================================================================
# Reusable IAM Module
# ==============================================================================
# Provisions least-privilege IAM execution roles and policies for:
# 1. Query Lambda (SSM read, DynamoDB read/write, Bedrock invoke, CloudWatch logs)
# 2. Ingestion Lambda (S3 documents read, Bedrock ingestion job, CloudWatch logs)
# ==============================================================================

# Shared Lambda Assume Role Trust Policy Document
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid     = "LambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ------------------------------------------------------------------------------
# Query Lambda IAM Role & Policy
# ------------------------------------------------------------------------------

resource "aws_iam_role" "query_lambda" {
  name               = "${var.name_prefix}-query-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "query_lambda" {
  # CloudWatch Logging Permissions
  statement {
    sid    = "CloudWatchLogsAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  # SSM Parameter Store Permission (Read Model ID & KB ID)
  statement {
    sid    = "SSMParameterReadAccess"
    effect = "Allow"
    actions = [
      "ssm:GetParameter"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/${var.name_prefix}/*",
      var.ssm_parameter_arn
    ]
  }

  # DynamoDB Conversation History Permissions
  statement {
    sid    = "DynamoDBConversationHistoryAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query"
    ]
    resources = [var.dynamodb_table_arn]
  }

  # Amazon Bedrock Model Invocation & RAG Permissions
  statement {
    sid    = "BedrockModelInvocationAccess"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
      "bedrock:GetInferenceProfile",
      "bedrock:Retrieve",
      "bedrock:RetrieveAndGenerate"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "query_lambda" {
  name        = "${var.name_prefix}-query-lambda-policy"
  description = "Least-privilege policy for Query Lambda execution role."
  policy      = data.aws_iam_policy_document.query_lambda.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "query_lambda" {
  role       = aws_iam_role.query_lambda.name
  policy_arn = aws_iam_policy.query_lambda.arn
}

# ------------------------------------------------------------------------------
# Ingestion Lambda IAM Role & Policy
# ------------------------------------------------------------------------------

resource "aws_iam_role" "ingestion_lambda" {
  name               = "${var.name_prefix}-ingestion-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "ingestion_lambda" {
  # CloudWatch Logging Permissions
  statement {
    sid    = "CloudWatchLogsAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  # S3 Documents Bucket Read Permissions
  statement {
    sid    = "S3DocumentsReadAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      var.documents_bucket_arn,
      "${var.documents_bucket_arn}/*"
    ]
  }

  # Amazon Bedrock Knowledge Base Ingestion Permissions
  statement {
    sid    = "BedrockIngestionAccess"
    effect = "Allow"
    actions = [
      "bedrock:StartIngestionJob",
      "bedrock:GetIngestionJob"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ingestion_lambda" {
  name        = "${var.name_prefix}-ingestion-lambda-policy"
  description = "Least-privilege policy for Ingestion Lambda execution role."
  policy      = data.aws_iam_policy_document.ingestion_lambda.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "ingestion_lambda" {
  role       = aws_iam_role.ingestion_lambda.name
  policy_arn = aws_iam_policy.ingestion_lambda.arn
}

# ------------------------------------------------------------------------------
# Bedrock Knowledge Base Service IAM Role & Policy
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "bedrock_kb_assume_role" {
  statement {
    sid     = "BedrockServiceAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bedrock_kb" {
  name               = "${var.name_prefix}-bedrock-kb-role"
  assume_role_policy = data.aws_iam_policy_document.bedrock_kb_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "bedrock_kb" {
  # Embedding Model Invocation Permission
  statement {
    sid       = "BedrockEmbeddingModelAccess"
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel"]
    resources = ["arn:aws:bedrock:*::foundation-model/amazon.titan-embed-text-v2:0"]
  }

  # S3 Documents Bucket Read Permission
  statement {
    sid     = "S3DocumentsReadAccess"
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      var.documents_bucket_arn,
      "${var.documents_bucket_arn}/*"
    ]
  }

  # OpenSearch Serverless Data Plane API Permission
  statement {
    sid       = "OpenSearchServerlessAPIAccess"
    effect    = "Allow"
    actions   = ["aoss:APIAccessAll"]
    resources = [var.opensearch_collection_arn]
  }
}

resource "aws_iam_policy" "bedrock_kb" {
  name        = "${var.name_prefix}-bedrock-kb-policy"
  description = "Execution policy for Amazon Bedrock Knowledge Base service."
  policy      = data.aws_iam_policy_document.bedrock_kb.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "bedrock_kb" {
  role       = aws_iam_role.bedrock_kb.name
  policy_arn = aws_iam_policy.bedrock_kb.arn
}

