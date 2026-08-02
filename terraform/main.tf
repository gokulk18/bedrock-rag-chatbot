
data "aws_caller_identity" "current" {}

module "documents" {
  source = "./modules/s3"

  bucket_name       = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-documents"
  enable_versioning = true
  enable_encryption = true

  tags = local.common_tags
}

module "ssm_bedrock_model_id" {
  source = "./modules/ssm"

  parameter_name        = "/${local.name_prefix}/bedrock/model-id"
  parameter_value       = var.bedrock_model_id
  parameter_description = "Amazon Bedrock foundation model ID for RAG Chatbot text generation."
  parameter_type        = "String"
  overwrite             = true

  tags = local.common_tags
}

module "conversation_history" {
  source = "./modules/dynamodb"

  table_name    = "${local.name_prefix}-conversations"
  hash_key      = "session_id"
  ttl_attribute = "ttl"

  tags = local.common_tags
}

module "iam" {
  source = "./modules/iam"

  name_prefix               = local.name_prefix
  documents_bucket_arn      = module.documents.bucket_arn
  dynamodb_table_arn        = module.conversation_history.table_arn
  ssm_parameter_arn         = module.ssm_bedrock_model_id.parameter_arn
  opensearch_collection_arn = module.opensearch.collection_arn

  tags = local.common_tags
}

module "opensearch" {
  source = "./modules/opensearch"

  collection_name = "${var.project_name}-${var.environment}-vec"
  iam_role_arns = [
    module.iam.query_lambda_role_arn,
    module.iam.ingestion_lambda_role_arn,
    module.iam.bedrock_kb_role_arn,
    data.aws_caller_identity.current.arn
  ]

  tags = local.common_tags
}

module "bedrock" {
  source = "./modules/bedrock"

  knowledge_base_name  = "${local.name_prefix}-kb"
  role_arn             = module.iam.bedrock_kb_role_arn
  collection_arn       = module.opensearch.collection_arn
  documents_bucket_arn = module.documents.bucket_arn
  embedding_model_arn  = "arn:aws:bedrock:${var.aws_region}::foundation-model/amazon.titan-embed-text-v2:0"

  tags = local.common_tags
}

module "ssm_bedrock_kb_id" {
  source = "./modules/ssm"

  parameter_name        = "/${local.name_prefix}/bedrock/knowledge-base-id"
  parameter_value       = module.bedrock.knowledge_base_id
  parameter_description = "Amazon Bedrock Knowledge Base ID for RAG Chatbot document retrieval."
  parameter_type        = "String"
  overwrite             = true

  tags = local.common_tags
}

module "ingestion_lambda" {
  source = "./modules/lambda"

  function_name = "${local.name_prefix}-ingestion"
  role_arn      = module.iam.ingestion_lambda_role_arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 60

  environment_variables = {
    KNOWLEDGE_BASE_ID_PARAM = module.ssm_bedrock_kb_id.parameter_name
    DATA_SOURCE_ID          = module.bedrock.data_source_id
  }

  enable_s3_trigger = true
  s3_bucket_id      = module.documents.bucket_id
  s3_bucket_arn     = module.documents.bucket_arn

  source_code = file("${path.module}/../backend/ingestion/index.py")

  tags = local.common_tags
}

resource "aws_s3_object" "initial_documents" {
  for_each = {
    for f in fileset("${path.module}/../documents", "**/*") : f => f
    if !endswith(f, ".gitkeep") && !startswith(f, ".")
  }

  bucket = module.documents.bucket_id
  key    = each.value
  source = "${path.module}/../documents/${each.value}"
  etag   = filemd5("${path.module}/../documents/${each.value}")

  depends_on = [
    module.bedrock,
    module.ingestion_lambda
  ]
}


module "query_lambda" {
  source = "./modules/lambda"

  function_name = "${local.name_prefix}-query"
  role_arn      = module.iam.query_lambda_role_arn
  handler       = "index.handler"
  runtime       = "python3.12"
  timeout       = 60
  memory_size   = 256

  environment_variables = {
    KNOWLEDGE_BASE_ID_PARAM = module.ssm_bedrock_kb_id.parameter_name
    CONVERSATION_TABLE_NAME = module.conversation_history.table_name
  }

  source_code = file("${path.module}/../backend/query/index.py")

  tags = local.common_tags
}


module "apigateway" {
  source = "./modules/apigateway"

  api_name             = "${local.name_prefix}-api"
  lambda_function_name = module.query_lambda.lambda_name
  lambda_invoke_arn    = module.query_lambda.invoke_arn

  tags = local.common_tags
}

module "frontend" {
  source = "./modules/s3"

  bucket_name       = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-frontend"
  enable_versioning = true
  enable_encryption = true

  tags = local.common_tags
}

module "cloudfront" {
  source = "./modules/cloudfront"

  oac_name                    = "${local.name_prefix}-oac"
  bucket_id                   = module.frontend.bucket_id
  bucket_arn                  = module.frontend.bucket_arn
  bucket_regional_domain_name = module.frontend.bucket_regional_domain_name

  tags = local.common_tags
}

module "sns" {
  source = "./modules/sns"

  topic_name    = "${local.name_prefix}-alerts"
  email_address = var.alert_email

  tags = local.common_tags
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  name_prefix                = local.name_prefix
  sns_topic_arn              = module.sns.topic_arn
  query_lambda_function_name = module.query_lambda.lambda_name
  api_id                     = module.apigateway.api_id
  dynamodb_table_name        = module.conversation_history.table_name

  tags = local.common_tags
}

module "budget" {
  source = "./modules/budget"

  budget_name   = "${local.name_prefix}-monthly-budget"
  limit_amount  = var.monthly_budget_limit
  sns_topic_arn = module.sns.topic_arn

  tags = local.common_tags
}

