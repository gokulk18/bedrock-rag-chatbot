# ==============================================================================
# S3 Module Input Variables
# ==============================================================================

variable "bucket_name" {
  type        = string
  description = "The globally unique name for the S3 bucket."
}

variable "enable_versioning" {
  type        = bool
  description = "Toggles S3 bucket versioning for object durability and history."
  default     = true
}

variable "enable_encryption" {
  type        = bool
  description = "Toggles AES256 server-side encryption for all bucket objects."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to apply to the S3 bucket."
  default     = {}
}
