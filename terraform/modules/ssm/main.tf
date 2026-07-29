variable "name_prefix" { type = string }
variable "aws_region" { type = string }
variable "model_id" { type = string }
variable "knowledge_base_id" { type = string }
variable "api_url" { type = string }
resource "aws_ssm_parameter" "region" {
  name  = "/${var.name_prefix}/aws-region"
  type  = "String"
  value = var.aws_region
}
resource "aws_ssm_parameter" "model" {
  name  = "/${var.name_prefix}/bedrock-model-id"
  type  = "String"
  value = var.model_id
}
resource "aws_ssm_parameter" "knowledge_base" {
  name  = "/${var.name_prefix}/knowledge-base-id"
  type  = "String"
  value = var.knowledge_base_id
}
resource "aws_ssm_parameter" "api" {
  name  = "/${var.name_prefix}/api-url"
  type  = "String"
  value = var.api_url
}
