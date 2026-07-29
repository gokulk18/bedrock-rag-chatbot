variable "name_prefix" { type = string }
variable "functions" {
  type = map(object({ source_dir = string, handler = string, role_arn = string, environment = map(string) }))
}
data "archive_file" "function" {
  for_each    = var.functions
  type        = "zip"
  source_dir  = each.value.source_dir
  output_path = "${path.module}/.build/${each.key}.zip"
}
resource "aws_lambda_function" "this" {
  for_each         = var.functions
  function_name    = "${var.name_prefix}-${each.key}"
  role             = each.value.role_arn
  handler          = each.value.handler
  runtime          = "python3.13"
  timeout          = 30
  memory_size      = 512
  filename         = data.archive_file.function[each.key].output_path
  source_code_hash = data.archive_file.function[each.key].output_base64sha256
  environment { variables = each.value.environment }
  tracing_config { mode = "Active" }
}
output "function_arns" { value = { for key, fn in aws_lambda_function.this : key => fn.arn } }
output "function_names" { value = { for key, fn in aws_lambda_function.this : key => fn.function_name } }
