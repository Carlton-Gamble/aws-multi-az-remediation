# Main Terraform Entry 
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Instantiate the custom VPC module
module "vpc" {
  source = "./modules/vpc"
}

module "security_groups" {
	source = "./modules/security_groups"
	vpc_id = module.vpc.vpc_id
}