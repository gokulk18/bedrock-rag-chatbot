
resource "aws_ssm_parameter" "this" {
  name        = var.parameter_name
  value       = var.parameter_value
  description = var.parameter_description != "" ? var.parameter_description : null
  type        = var.parameter_type
  overwrite   = var.overwrite
  tags        = var.tags
}
