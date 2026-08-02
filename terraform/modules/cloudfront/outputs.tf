
output "distribution_id" {
  description = "ID of the created CloudFront distribution."
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "ARN of the created CloudFront distribution."
  value       = aws_cloudfront_distribution.this.arn
}

output "domain_name" {
  description = "Domain name of the created CloudFront distribution."
  value       = aws_cloudfront_distribution.this.domain_name
}
