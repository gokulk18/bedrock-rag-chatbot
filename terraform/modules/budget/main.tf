# ==============================================================================
# Reusable AWS Budgets Module
# ==============================================================================
# Provisions a monthly USD cost budget with automated notifications at 80% and 100%
# thresholds sent to an SNS topic.
# ==============================================================================

resource "aws_budgets_budget" "this" {
  name              = var.budget_name
  budget_type       = "COST"
  limit_amount      = tostring(var.limit_amount)
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2026-01-01_00:00"

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [var.sns_topic_arn]
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [var.sns_topic_arn]
  }

  tags = var.tags
}
