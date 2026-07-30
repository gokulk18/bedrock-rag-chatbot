# ==============================================================================
# Reusable Amazon SNS Topic Module
# ==============================================================================
# Provisions an Amazon SNS topic for system alerts and configures an optional
# email subscription for administrative notifications.
# ==============================================================================

resource "aws_sns_topic" "this" {
  name = var.topic_name
  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  count     = (var.email_address != null && var.email_address != "") ? 1 : 0
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.email_address
}
