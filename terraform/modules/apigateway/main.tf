# ==============================================================================
# Reusable Amazon API Gateway HTTP API Module
# ==============================================================================
# Provisions a low-latency HTTP API Gateway instance configured with:
# - CORS configuration for cross-origin browser access
# - AWS_PROXY integration with Query Lambda (Payload 2.0)
# - POST /chat route
# - $default auto-deployment stage
# - Least-privilege Lambda invocation permissions
# ==============================================================================

# ------------------------------------------------------------------------------
# HTTP API Gateway Container
# ------------------------------------------------------------------------------
resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  protocol_type = "HTTP"
  description   = "API Gateway HTTP API for Amazon Bedrock RAG Chatbot."

  cors_configuration {
    allow_headers = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_origins = var.allowed_origins
    max_age       = 300
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Lambda Proxy Integration
# ------------------------------------------------------------------------------
resource "aws_apigatewayv2_integration" "query_lambda" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# ------------------------------------------------------------------------------
# POST /chat Route Definition
# ------------------------------------------------------------------------------
resource "aws_apigatewayv2_route" "chat" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "POST /chat"
  target    = "integrations/${aws_apigatewayv2_integration.query_lambda.id}"
}

# ------------------------------------------------------------------------------
# Default ($default) Auto-Deployed Stage
# ------------------------------------------------------------------------------
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Lambda Invocation Permission
# ------------------------------------------------------------------------------
# Grants API Gateway execution scope permission to invoke ONLY the Query Lambda
# for the POST /chat route.
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvokeChat"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*/chat"
}
