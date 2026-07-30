# ==============================================================================
# API Gateway Module Outputs
# ==============================================================================

output "api_id" {
  description = "ID of the created API Gateway HTTP API."
  value       = aws_apigatewayv2_api.this.id
}

output "api_arn" {
  description = "ARN of the created API Gateway HTTP API."
  value       = aws_apigatewayv2_api.this.arn
}

output "api_endpoint" {
  description = "Direct endpoint URL of the created API Gateway HTTP API."
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "invoke_url" {
  description = "Default stage invocation URL for the API Gateway HTTP API."
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "chat_endpoint_url" {
  description = "Full URL for the POST /chat endpoint."
  value       = "${aws_apigatewayv2_stage.default.invoke_url}chat"
}
