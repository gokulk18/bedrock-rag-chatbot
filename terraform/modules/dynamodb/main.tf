variable "table_name" { type = string }
resource "aws_dynamodb_table" "conversations" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "session_id"
  range_key    = "timestamp"
  attribute {
    name = "session_id"
    type = "S"
  }
  attribute {
    name = "timestamp"
    type = "S"
  }
  point_in_time_recovery { enabled = true }
  server_side_encryption { enabled = true }
}
output "table_name" { value = aws_dynamodb_table.conversations.name }
output "table_arn" { value = aws_dynamodb_table.conversations.arn }
