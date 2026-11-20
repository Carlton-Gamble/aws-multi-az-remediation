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

# 1. Core VPC Infrastructure
module "vpc" {
  source = "./modules/vpc"
}

# 2. Tiered Security Group Chaining
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

# 3. Application Load Balancer
module "alb" {
  source = "./modules/alb"

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_sg_id
}

# 4. Private Compute & Auto Scaling Tier
module "compute" {
  source = "./modules/compute"

  vpc_id                 = module.vpc.vpc_id
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  app_security_group_id  = module.security_groups.app_sg_id
  target_group_arn       = module.alb.target_group_arn
}

# 5. GuardDuty Automated Threat Remediation Engine
module "remediation" {
  source = "./modules/remediation"

  vpc_id = module.vpc.vpc_id
}