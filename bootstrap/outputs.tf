# ==============================================================================
# Outputs
# ==============================================================================
# Exports key attributes of the created remote state S3 bucket and provides
# a ready-to-use HCL backend configuration block for the main Terraform project.
# ==============================================================================

output "s3_bucket_name" {
  description = "Name of the S3 bucket created for Terraform remote state storage."
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket created for Terraform remote state storage."
  value       = aws_s3_bucket.terraform_state.arn
}

output "aws_region" {
  description = "AWS region where the bootstrap S3 backend bucket resides."
  value       = var.aws_region
}

output "backend_config_instructions" {
  description = "Formatted HCL block to paste directly into terraform/backend.tf for the main infrastructure project."
  value       = <<EOT
terraform {
  backend "s3" {
    bucket       = "${aws_s3_bucket.terraform_state.id}"
    key          = "${var.project_name}/terraform.tfstate"
    region       = "${var.aws_region}"
    use_lockfile = true
  }
}
EOT
}

output "github_actions_terraform_role_arn" {
  description = "ARN of the IAM role for GitHub Actions Terraform CI/CD."
  value       = aws_iam_role.github_actions_terraform.arn
}

output "github_actions_lambda_role_arn" {
  description = "ARN of the IAM role for GitHub Actions Lambda deployment."
  value       = aws_iam_role.github_actions_lambda.arn
}

output "github_actions_frontend_role_arn" {
  description = "ARN of the IAM role for GitHub Actions Frontend deployment."
  value       = aws_iam_role.github_actions_frontend.arn
}

