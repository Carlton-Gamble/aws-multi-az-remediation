resource "aws_vpc" "main" {
	cidr_block = var.vpc_cidr
	enable_dns_hostnames = true
	enable_dns_support = true

	tags = {
		Name = "main-vpc"
	}

}

resource "aws_internet_gateway" "gw" {
	vpc_id = aws_vpc.main.id

	tags = {
		Name = "main-igw"
	}
}

resource "aws_subnet" "public" {
	count = length(var.public_subnet_cidrs)
	vpc_id = aws_vpc.main.id
	cidr_block = var.public_subnet_cidrs[count.index]
	availability_zone = var.availability_zones[count.index]
	map_public_ip_on_launch = true

	tags = {
		Name = "public-subnet-${count.index + 1}"
	}
}

resource "aws_subnet" "private_app" {
	count = length(var.private_app_subnet_cidrs)
	vpc_id = aws_vpc.main.id
	cidr_block = var.private_app_subnet_cidrs[count.index]
	availability_zone = var.availability_zones[count.index]

	tags = {
		Name = "private-app-subnet-${count.index + 1}"
	}
}

resource "aws_subnet" "private_db" {
	count = length(var.private_db_subnet_cidrs)
	vpc_id = aws_vpc.main.id
	cidr_block = var.private_db_subnet_cidrs[count.index]
	availability_zone = var.availability_zones[count.index]

	tags = {
		Name = "private-db-subnet-${count.index + 1}"
	}
}