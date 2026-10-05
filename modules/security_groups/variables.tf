variable "vpc_id" {
	type = string
	description = "The VPC ID where security groups will be created"
}

variable "vpc_cidr" {
	type = string
	default = "10.0.0.0/16"
	description = "CIDR block of the custom VPC"
}