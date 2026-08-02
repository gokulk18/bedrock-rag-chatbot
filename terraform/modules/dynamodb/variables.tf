
variable "table_name" {
  type        = string
  description = "Name of the DynamoDB table."
}

variable "hash_key" {
  type        = string
  description = "Attribute name used as the primary partition key."
  default     = "session_id"
}

variable "ttl_attribute" {
  type        = string
  description = "Attribute name used for DynamoDB Time-To-Live (TTL) expiration."
  default     = "ttl"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to apply to the DynamoDB table."
  default     = {}
}
