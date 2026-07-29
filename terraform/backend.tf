# ==============================================================================
# Remote S3 Backend Configuration
# ==============================================================================
# Configures Terraform to store state remotely in the Amazon S3 bucket created
# during Phase 1 (Bootstrap project).
#
# State Locking Strategy:
# Uses native S3 locking (use_lockfile = true), introduced in Terraform 1.15.
# This eliminates the requirement for an Amazon DynamoDB lock table by leveraging
# S3 strong consistency and native conditional write primitives (.tflock files).
# ==============================================================================

terraform {
  backend "s3" {
    # Specify the S3 bucket created during Phase 1 Bootstrap
    bucket       = "bedrock-rag-chatbot-dev-tfstate-bucket"
    key          = "bedrock-rag-chatbot/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
