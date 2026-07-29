variable "name_prefix" { type = string }
variable "documents_bucket_name" { type = string }
variable "ingestion_lambda_arn" { type = string }
variable "ingestion_lambda_name" { type = string }
resource "aws_cloudwatch_event_rule" "document_upload" {
  name          = "${var.name_prefix}-document-sync"
  event_pattern = jsonencode({ source = ["aws.s3"], detail-type = ["Object Created", "Object Deleted"], detail = { bucket = { name = [var.documents_bucket_name] } } })
}
resource "aws_cloudwatch_event_target" "ingestion" {
  rule = aws_cloudwatch_event_rule.document_upload.name
  arn  = var.ingestion_lambda_arn
}
resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowEventBridgeIngestion"
  action        = "lambda:InvokeFunction"
  function_name = var.ingestion_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.document_upload.arn
}
