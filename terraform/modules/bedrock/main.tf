variable "name_prefix" { type = string }
variable "source_bucket_arn" { type = string }
variable "source_bucket_name" { type = string }
variable "kb_role_arn" { type = string }
variable "embedding_model_arn" { type = string }
variable "vector_dimension" { type = number }

resource "aws_s3vectors_vector_bucket" "this" {
  vector_bucket_name = "${var.name_prefix}-vectors"
}
resource "aws_s3vectors_index" "this" {
  index_name         = "knowledge-base"
  vector_bucket_name = aws_s3vectors_vector_bucket.this.vector_bucket_name
  data_type          = "float32"
  dimension          = var.vector_dimension
  distance_metric    = "cosine"
}
resource "aws_bedrockagent_knowledge_base" "this" {
  name     = "${var.name_prefix}-kb"
  role_arn = var.kb_role_arn
  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = var.embedding_model_arn
      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          dimensions          = var.vector_dimension
          embedding_data_type = "FLOAT32"
        }
      }
    }
  }
  storage_configuration {
    type = "S3_VECTORS"
    s3_vectors_configuration { index_arn = aws_s3vectors_index.this.index_arn }
  }
}
resource "aws_bedrockagent_data_source" "documents" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.this.id
  name              = "documents"
  data_source_configuration {
    type = "S3"
    s3_configuration { bucket_arn = var.source_bucket_arn }
  }
}
output "knowledge_base_id" { value = aws_bedrockagent_knowledge_base.this.id }
output "knowledge_base_arn" { value = aws_bedrockagent_knowledge_base.this.arn }
output "data_source_id" { value = aws_bedrockagent_data_source.documents.data_source_id }
output "vector_index_arn" { value = aws_s3vectors_index.this.index_arn }
