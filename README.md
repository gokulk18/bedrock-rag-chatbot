# Amazon Bedrock RAG Chatbot

Production-style, serverless Amazon Bedrock RAG chatbot infrastructure built with Terraform.

## Project Status & Implemented Infrastructure (Phases 1–13)

This repository currently implements the foundational Terraform infrastructure up to Phase 13:

1. **Phase 1: Terraform Bootstrap (`bootstrap/`)**
   - Remote S3 state bucket with versioning, AES256 server-side encryption, ownership controls, and native S3 state locking (`use_lockfile = true`).

2. **Phase 2: Terraform Foundation (`terraform/`)**
   - Core root configuration (`backend.tf`, `versions.tf`, `providers.tf`, `variables.tf`, `locals.tf`, `outputs.tf`, `main.tf`).
   - Strict version requirements (Terraform CLI `>= 1.15.0`, AWS Provider `~> 6.56.0`).

3. **Phase 3: Reusable S3 Module (`terraform/modules/s3`)**
   - Production-grade S3 bucket for Knowledge Base documents with encryption, versioning, ownership controls, and public access blocks.

4. **Phase 4: Reusable SSM Module (`terraform/modules/ssm`)**
   - AWS Systems Manager Parameter Store resource for storing the Bedrock Model ID (`var.bedrock_model_id`).

5. **Phase 5: Reusable DynamoDB Module (`terraform/modules/dynamodb`)**
   - Amazon DynamoDB Conversation History table with `PAY_PER_REQUEST` billing mode, `session_id` partition key, TTL expiration, server-side encryption, and Point-in-Time Recovery (PITR).

6. **Phase 6: Reusable IAM Module (`terraform/modules/iam`)**
   - Least-privilege IAM execution roles, trust policies, and permission policies for Query Lambda, Ingestion Lambda, and Bedrock Knowledge Base service execution.

7. **Phase 7: Reusable OpenSearch Serverless Module (`terraform/modules/opensearch`)**
   - Amazon OpenSearch Serverless `VECTORSEARCH` collection with encryption security policies, network security policies, and least-privilege data access policies.

8. **Phase 8: Reusable Bedrock Module (`terraform/modules/bedrock`)**
   - Amazon Bedrock Knowledge Base with Titan Text Embeddings V2, OpenSearch Serverless vector storage binding, S3 Data Source, and SSM parameter storing the Knowledge Base ID (`/bedrock/knowledge-base-id`).

9. **Phase 9: Reusable Lambda Module (`terraform/modules/lambda`)**
   - Ingestion Lambda function with Python 3.12 runtime, CloudWatch log retention, S3 event notification triggers (`s3:ObjectCreated:*`), and automatic Bedrock ingestion job initiation.

10. **Phase 10: Query Lambda Function (`terraform/modules/lambda`)**
    - Query Lambda function orchestrating RAG chat requests, SSM parameter lookups, DynamoDB multi-turn session history, Bedrock `RetrieveAndGenerate` model calls, and formatted JSON responses with citations.

11. **Phase 11: Reusable API Gateway Module (`terraform/modules/apigateway`)**
    - Amazon API Gateway HTTP API exposing `POST /chat` route backed by `AWS_PROXY` integration to Query Lambda with CORS support (`POST`, `OPTIONS`), `$default` auto-deployment stage, and scoped Lambda execution permissions.

12. **Phase 12: Frontend Hosting & CloudFront OAC (`terraform/modules/cloudfront`)**
    - Private frontend S3 bucket (reusing generic S3 module) and global CloudFront CDN distribution with Origin Access Control (OAC), SigV4 signed requests, HTTPS redirection, and default root object `index.html`.

13. **Phase 13: Monitoring, Alerting & Cost Management (`terraform/modules/sns`, `cloudwatch`, `budget`)**
    - CloudWatch metric alarms for Query Lambda errors, API Gateway 5XX errors, and DynamoDB throttles publishing to an SNS topic with email subscription, plus a monthly USD AWS cost budget with 80% and 100% notification thresholds.

## Deployment

1. Initialize and apply the bootstrap state backend in `bootstrap/`:
   ```bash
   cd bootstrap
   terraform init
   terraform apply
   ```

2. Initialize and deploy the core infrastructure in `terraform/`:
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

