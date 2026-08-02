
variable "oac_name" {
  type        = string
  description = "Name of the CloudFront Origin Access Control (OAC) resource."
}

variable "bucket_id" {
  type        = string
  description = "ID/Name of the frontend S3 bucket."
}

variable "bucket_arn" {
  type        = string
  description = "ARN of the frontend S3 bucket."
}

variable "bucket_regional_domain_name" {
  type        = string
  description = "Regional domain name of the frontend S3 bucket."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags to apply to CloudFront resources."
  default     = {}
}
