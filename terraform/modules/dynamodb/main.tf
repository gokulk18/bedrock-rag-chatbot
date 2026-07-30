# ==============================================================================
# Reusable DynamoDB Table Module
# ==============================================================================
# Provisions a production-grade Amazon DynamoDB table with:
# - PAY_PER_REQUEST (On-Demand) capacity mode
# - Server-side encryption enabled
# - Point-in-time recovery (PITR) enabled
# - Time-to-Live (TTL) attribute expiration
# ==============================================================================

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = "S"
  }

  ttl {
    attribute_name = var.ttl_attribute
    enabled        = true
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = var.tags
}
