
variable "parameter_name" {
  type        = string
  description = "The name / key path of the SSM parameter (e.g., /app/dev/service/key)."
}

variable "parameter_value" {
  type        = string
  description = "The value to store in the SSM parameter."
}

variable "parameter_description" {
  type        = string
  description = "Description explaining the purpose of the SSM parameter."
  default     = ""
}

variable "parameter_type" {
  type        = string
  description = "The type of the parameter. Valid values: String, StringList, SecureString."
  default     = "String"
}

variable "overwrite" {
  type        = bool
  description = "Whether to overwrite an existing parameter with the same name."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to apply to the SSM parameter."
  default     = {}
}
