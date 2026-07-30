# ==============================================================================
# Remote S3 Backend Configuration
# ==============================================================================
# Stores Terraform state in an S3 bucket created by the bootstrap step.
# ==============================================================================

terraform {
  backend "s3" {
    bucket = "bedrock-rag-chatbot-dev-tfstate"
    key    = "bedrock-rag-chatbot/terraform.tfstate"
    region = "us-east-1"
  }
}
