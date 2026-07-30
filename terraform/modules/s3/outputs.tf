# ==============================================================================
# S3 Module Outputs
# ==============================================================================

output "bucket_id" {
  description = "The name/ID of the created S3 bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_name" {
  description = "The name of the created S3 bucket."
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "The ARN of the created S3 bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the created S3 bucket."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

