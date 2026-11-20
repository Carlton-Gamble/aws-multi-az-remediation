output "alb_dns_name" {
  description = "Public DNS URL to access the load-balanced web application"
  value       = module.alb.alb_dns_name
}

output "vpc_id" {
  description = "ID of the provisioned custom VPC"
  value       = module.vpc.vpc_id
}

output "remediation_lambda_arn" {
  description = "ARN of the automated GuardDuty remediation Lambda function"
  value       = module.remediation.remediation_lambda_arn
}