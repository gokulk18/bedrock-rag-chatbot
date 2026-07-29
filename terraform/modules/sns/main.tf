variable "name_prefix" { type = string }
resource "aws_sns_topic" "alerts" { name = "${var.name_prefix}-alerts" }
output "alert_topic_arn" { value = aws_sns_topic.alerts.arn }
