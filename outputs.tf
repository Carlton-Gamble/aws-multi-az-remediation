# Global Outputs 
output "vpc_id" {
	description = "The ID of the deployed multi-AZ VPC"
	value = module.vpc.vpc_id
}

output "public_subnet_ids"{
	description = "Public subnet IDs"
	value = module.vpc.public_subnet_ids

}