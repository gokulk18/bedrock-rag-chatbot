# Bedrock RAG Chatbot

Production-style, serverless RAG chatbot infrastructure built with Terraform.

## Architecture

Private S3 documents trigger EventBridge events. An ingestion Lambda starts an Amazon Bedrock Knowledge Bases ingestion job, which embeds document chunks with Titan Text Embeddings V2 and stores them in Amazon S3 Vectors. API Gateway invokes the query Lambda, which calls Bedrock `RetrieveAndGenerate` using Amazon Nova Micro.

The deployment also creates DynamoDB conversation storage, a private S3 + CloudFront frontend origin, SSM configuration parameters, SNS alerts, and a monthly budget.

## Deploy

1. Install Terraform `1.15.8` or newer and configure AWS credentials for `us-east-1`.
2. In the Bedrock console, enable access to `amazon.nova-micro-v1:0` and `amazon.titan-embed-text-v2:0`.
3. From `terraform/`, run `terraform init -upgrade`, `terraform plan`, then `terraform apply`.
4. Confirm the optional SNS email subscription and upload files to the `documents_bucket` Terraform output.

Use `terraform destroy` when the demonstration environment is no longer needed. S3 Vectors, Bedrock inference, and other AWS services can incur charges.

Initial repository setup for the Bedrock RAG chatbot project.
