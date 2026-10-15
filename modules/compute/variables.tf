variable "vpc_id" {
	type = string
	description = "ID of the custom VPC"
}

variable "private_app_subnet_ids" {
	type = list(string)
	description = "List of private application subnet IDs across us-east-1a and us-east-1b"
}

variable "app_security_group_id" {
	type = string
	description = "ID of the App Tier security group"
}

variable "target_group_arn" {
	type = string
	description = "ARN of the ALB target group"
}