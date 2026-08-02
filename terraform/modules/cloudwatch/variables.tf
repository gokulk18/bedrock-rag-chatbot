
variable "name_prefix" {
  type        = string
  description = "Resource name prefix for CloudWatch alarms."
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN of the SNS topic to publish alarm state notifications."
}

variable "query_lambda_function_name" {
  type        = string
  description = "Name of the Query Lambda function to monitor."
}

variable "api_id" {
  type        = string
  description = "ID of the API Gateway HTTP API to monitor."
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name of the Conversation History DynamoDB table to monitor."
}

variable "lambda_error_threshold" {
  type        = number
  description = "Threshold count for Query Lambda errors."
  default     = 1
}

variable "api_5xx_threshold" {
  type        = number
  description = "Threshold count for API Gateway 5XX errors."
  default     = 1
}

variable "dynamodb_throttle_threshold" {
  type        = number
  description = "Threshold count for DynamoDB throttled requests."
  default     = 1
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to apply to CloudWatch resources."
  default     = {}
}
