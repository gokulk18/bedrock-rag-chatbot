
terraform {
  backend "s3" {
    bucket       = "bedrock-rag-chatbot-dev-tfstate"
    key          = "bedrock-rag-chatbot/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
