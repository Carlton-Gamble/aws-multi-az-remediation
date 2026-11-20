variable "vpc_id" {
	type = string
	description = "ID of the custom VPC"
}

variable "public_subnet_ids" {
	type = list(string)
	description = "List of public subnet IDs for the Application Load Balancer"
}

variable "alb_security_group_id" {
	type = string
	description = "Security Group ID attached to the ALB"
}