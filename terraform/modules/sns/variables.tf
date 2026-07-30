# ==============================================================================
# SNS Module Input Variables
# ==============================================================================

variable "topic_name" {
  type        = string
  description = "Name of the Amazon SNS topic."
}

variable "email_address" {
  type        = string
  description = "Optional email address to subscribe for alert notifications."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to apply to SNS resources."
  default     = {}
}
