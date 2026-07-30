output "s3_bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.arn
}

output "aws_region" {
  description = "AWS region where the bootstrap backend bucket was created."
  value       = var.aws_region
}

output "backend_config_example" {
  description = "Example backend block for the main infrastructure project."
  value       = <<EOT
terraform {
  backend "s3" {
    bucket       = "${aws_s3_bucket.terraform_state.id}"
    key          = "bedrock-rag-chatbot/terraform.tfstate"
    region       = "${var.aws_region}"
    use_lockfile = true
  }
}
EOT
}
