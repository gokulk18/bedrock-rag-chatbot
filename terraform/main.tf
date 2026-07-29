data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  name_prefix          = "${var.project_name}-${var.environment}"
  embedding_model_id   = "amazon.titan-embed-text-v2:0"
  embedding_dimension  = 256
  embedding_model_arn  = "arn:${data.aws_partition.current.partition}:bedrock:${var.aws_region}::foundation-model/${local.embedding_model_id}"
  generation_model_arn = "arn:${data.aws_partition.current.partition}:bedrock:${var.aws_region}::foundation-model/${var.bedrock_model_id}"
}

module "documents" {
  source      = "./modules/s3"
  bucket_name = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-documents"
}

module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = "${local.name_prefix}-conversations"
}

module "bedrock" {
  source              = "./modules/bedrock"
  name_prefix         = local.name_prefix
  source_bucket_arn   = module.documents.bucket_arn
  source_bucket_name  = module.documents.bucket_name
  kb_role_arn         = module.iam.bedrock_kb_role_arn
  embedding_model_arn = local.embedding_model_arn
  vector_dimension    = local.embedding_dimension
}

module "iam" {
  source                  = "./modules/iam"
  name_prefix             = local.name_prefix
  documents_bucket_arn    = module.documents.bucket_arn
  vector_index_arn        = module.bedrock.vector_index_arn
  embedding_model_arn     = local.embedding_model_arn
  generation_model_arn    = local.generation_model_arn
  knowledge_base_arn      = module.bedrock.knowledge_base_arn
  conversations_table_arn = module.dynamodb.table_arn
}

module "lambda" {
  source      = "./modules/lambda"
  name_prefix = local.name_prefix
  functions = {
    query = {
      source_dir = "${path.root}/../lambda/query"
      handler    = "handler.lambda_handler"
      role_arn   = module.iam.query_lambda_role_arn
      environment = {
        KNOWLEDGE_BASE_ID   = module.bedrock.knowledge_base_id
        MODEL_ARN           = local.generation_model_arn
        CONVERSATIONS_TABLE = module.dynamodb.table_name
      }
    }
    ingestion = {
      source_dir = "${path.root}/../lambda/ingestion"
      handler    = "handler.lambda_handler"
      role_arn   = module.iam.ingestion_lambda_role_arn
      environment = {
        KNOWLEDGE_BASE_ID = module.bedrock.knowledge_base_id
        DATA_SOURCE_ID    = module.bedrock.data_source_id
      }
    }
  }
}

module "api" {
  source            = "./modules/apigateway"
  name_prefix       = local.name_prefix
  query_lambda_arn  = module.lambda.function_arns["query"]
  query_lambda_name = module.lambda.function_names["query"]
}

module "sync" {
  source                = "./modules/cloudwatch"
  name_prefix           = local.name_prefix
  documents_bucket_name = module.documents.bucket_name
  ingestion_lambda_arn  = module.lambda.function_arns["ingestion"]
  ingestion_lambda_name = module.lambda.function_names["ingestion"]
}

module "frontend" {
  source      = "./modules/cloudfront"
  bucket_name = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}-${var.aws_region}-frontend"
}

module "ssm" {
  source            = "./modules/ssm"
  name_prefix       = local.name_prefix
  aws_region        = var.aws_region
  model_id          = var.bedrock_model_id
  knowledge_base_id = module.bedrock.knowledge_base_id
  api_url           = module.api.api_endpoint
}

module "sns" {
  source      = "./modules/sns"
  name_prefix = local.name_prefix
}

module "budget" {
  source      = "./modules/budget"
  name_prefix = local.name_prefix
  limit_usd   = var.budget_limit_usd
  alert_email = var.budget_alert_email
  topic_arn   = module.sns.alert_topic_arn
}
