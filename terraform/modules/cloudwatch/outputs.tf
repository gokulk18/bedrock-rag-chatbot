# ==============================================================================
# CloudWatch Module Outputs
# ==============================================================================

output "alarm_names" {
  description = "List of created CloudWatch alarm names."
  value = [
    aws_cloudwatch_metric_alarm.lambda_errors.alarm_name,
    aws_cloudwatch_metric_alarm.api_5xx.alarm_name,
    aws_cloudwatch_metric_alarm.dynamodb_throttles.alarm_name
  ]
}

output "lambda_error_alarm_arn" {
  description = "ARN of the Query Lambda error alarm."
  value       = aws_cloudwatch_metric_alarm.lambda_errors.arn
}

output "api_5xx_alarm_arn" {
  description = "ARN of the API Gateway 5XX error alarm."
  value       = aws_cloudwatch_metric_alarm.api_5xx.arn
}

output "dynamodb_throttle_alarm_arn" {
  description = "ARN of the DynamoDB throttled requests alarm."
  value       = aws_cloudwatch_metric_alarm.dynamodb_throttles.arn
}
