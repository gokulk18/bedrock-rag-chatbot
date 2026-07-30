# ==============================================================================
# Lambda Module Input Variables
# ==============================================================================

variable "function_name" {
  type        = string
  description = "Name of the AWS Lambda function."
}

variable "role_arn" {
  type        = string
  description = "IAM role ARN assumed by the Lambda function execution runtime."
}

variable "source_code" {
  type        = string
  description = "Python source code content to package into index.py."
}

variable "handler" {
  type        = string
  description = "Function entrypoint handler."
  default     = "index.handler"
}

variable "runtime" {
  type        = string
  description = "Lambda runtime language environment."
  default     = "python3.12"
}

variable "timeout" {
  type        = number
  description = "Function execution timeout in seconds."
  default     = 60
}

variable "memory_size" {
  type        = number
  description = "Amount of memory allocated to the Lambda function in MB."
  default     = 128
}

variable "log_retention_in_days" {
  type        = number
  description = "Number of days to retain CloudWatch logs."
  default     = 14
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment key-value pairs passed to the Lambda function."
  default     = {}
}

variable "s3_bucket_id" {
  type        = string
  description = "Optional S3 bucket ID for configuring event notification triggers."
  default     = null
}

variable "s3_bucket_arn" {
  type        = string
  description = "Optional S3 bucket ARN for configuring Lambda execution permissions."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to apply to the Lambda function and log group."
  default     = {}
}
