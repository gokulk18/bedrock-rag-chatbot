
output "lambda_name" {
  description = "Name of the created Lambda function."
  value       = aws_lambda_function.this.function_name
}

output "lambda_arn" {
  description = "ARN of the created Lambda function."
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "API Gateway invocation ARN of the created Lambda function."
  value       = aws_lambda_function.this.invoke_arn
}
