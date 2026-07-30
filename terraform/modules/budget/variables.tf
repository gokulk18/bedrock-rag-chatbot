# ==============================================================================
# AWS Budget Module Input Variables
# ==============================================================================

variable "budget_name" {
  type        = string
  description = "Name of the AWS Budget."
}

variable "limit_amount" {
  type        = number
  description = "Monthly cost limit amount in USD."
  default     = 50
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN of the SNS topic to receive budget threshold notifications."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to apply to budget resources."
  default     = {}
}
