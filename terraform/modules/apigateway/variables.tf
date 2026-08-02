
variable "api_name" {
  type        = string
  description = "Name of the API Gateway HTTP API."
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Query Lambda function to receive invocations."
}

variable "lambda_invoke_arn" {
  type        = string
  description = "Invocation ARN of the Query Lambda function."
}

variable "allowed_origins" {
  type        = list(string)
  description = "List of allowed origins for Cross-Origin Resource Sharing (CORS)."
  default     = ["*"]
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to apply to API Gateway resources."
  default     = {}
}
