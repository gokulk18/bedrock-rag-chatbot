# ==============================================================================
# AWS Budget Module Outputs
# ==============================================================================

output "budget_name" {
  description = "Name of the created AWS Budget."
  value       = aws_budgets_budget.this.name
}

output "budget_id" {
  description = "ID of the created AWS Budget."
  value       = aws_budgets_budget.this.id
}
