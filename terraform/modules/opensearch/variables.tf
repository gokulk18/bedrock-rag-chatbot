
variable "collection_name" {
  type        = string
  description = "Name of the OpenSearch Serverless collection (must be 3-32 lowercase alphanumeric characters or hyphens)."

  validation {
    condition     = can(regex("^[a-z0-9-]{3,32}$", var.collection_name))
    error_message = "collection_name must be between 3 and 32 characters long, containing only lowercase letters, numbers, and hyphens."
  }
}

variable "iam_role_arns" {
  type        = list(string)
  description = "List of IAM role/user ARNs granted data access permissions to the collection."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to apply to the OpenSearch Serverless collection."
  default     = {}
}
