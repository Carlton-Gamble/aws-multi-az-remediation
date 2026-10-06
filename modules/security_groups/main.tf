resource "aws_security_group" "alb_sg" {
	name = "alb-security-group"
	description = "Allow public inbound HTTP/HTTPs traffic"
	vpc_id = var.vpc_id

	ingress {
		description = "Allow HTTP from internet"
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		description = "Allow HTTPS from internet"
		from_port = 443
		to_port = 443
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		description = "Allow all outbound traffic"
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	tags = {
		Name = "alb-security-group"
	}
}

resource "aws_security_group" "app_sg" {
	name = "app-security-group"
	description = "Allow inbound HTTP traffic ONLY from the ALB Security Group"
	vpc_id = var.vpc_id

	ingress {
		description = "Allow HTTP from ALB SG"
		from_port = 80
		to_port = 80
		protocol = "tcp"
		security_groups = [aws_security_group.alb_sg.id]
	}

	egress {
		description = "Allow all outbound traffic"
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "app-security-group"
	}
}

resource "aws_security_group" "db_sg" {
	name = "db-security-group"
	description = "Allow inbound MySQL traffic ONLY from App Security Group"
	vpc_id = var.vpc_id

	ingress {
		description = "Allow MySQL from App SG"
		from_port = 3306
		to_port = 3306
		protocol = "tcp"
		security_groups = [aws_security_group.app_sg.id]
	}

	egress {
		description = "Allow all outbound traffic"
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "db-security-group"
	}
}