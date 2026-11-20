output "quarantine_security_group_id" {
  description = "ID of the Quarantine Security Group"
  value       = aws_security_group.quarantine_sg.id
}

output "remediation_lambda_arn" {
  description = "ARN of the Lambda auto-remediation function"
  value       = aws_lambda_function.remediation_fn.arn
}