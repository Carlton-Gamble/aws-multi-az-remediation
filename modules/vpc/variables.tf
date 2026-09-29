variable "vpc_cidr" {
	type = string
	default = "10.0.0.0/16"
	description = "Base CIDR block for the custom VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "Public subnets spanning two Availability Zones"
}

variable "private_app_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
  description = "Private app subnets for Auto Scaling Group"
}

variable "private_db_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.200.0/24"]
  description = "Private database subnets for Multi-AZ RDS"
}

variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "Target Availability Zones"
}