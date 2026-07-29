variable "name_prefix" { type = string }
variable "limit_usd" { type = number }
variable "alert_email" { type = string }
variable "topic_arn" { type = string }
resource "aws_sns_topic_subscription" "email" {
  count     = var.alert_email == "" ? 0 : 1
  topic_arn = var.topic_arn
  protocol  = "email"
  endpoint  = var.alert_email
}
resource "aws_budgets_budget" "monthly" {
  name         = "${var.name_prefix}-monthly"
  budget_type  = "COST"
  limit_amount = tostring(var.limit_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [var.topic_arn]
  }
}
