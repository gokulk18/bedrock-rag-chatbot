# ==============================================================================
# SSM Module Outputs
# ==============================================================================

output "parameter_name" {
  description = "The name of the created SSM parameter."
  value       = aws_ssm_parameter.this.name
}

output "parameter_arn" {
  description = "The ARN of the created SSM parameter."
  value       = aws_ssm_parameter.this.arn
}

output "parameter_version" {
  description = "The version of the created SSM parameter."
  value       = aws_ssm_parameter.this.version
}
