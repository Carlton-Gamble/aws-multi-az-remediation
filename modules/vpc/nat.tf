#Left off here
#look for nat.tf sec

data "aws_ami" "amazon_linux_2023" {
	most_recent = true
	owners = ["amazon"]

	filter {
	name = "name"
	values = ["al2023-ami-2023.*-x86_64"]
	}
}

resource "aws_security_group" "nat_sg" {
	name = "nat-instance-sg"
	description = "Allow inbound web traffic from private subnets for NAT outbound routing"
	vpc_id = aws_vpc.main.id

	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = [var.vpc_cidr]
	}

	ingress {
		from_port = 443
		to_port = 443
		protocol = "tcp"
		cidr_blocks = [var.vpc_cidr]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "nat-instance-sg"
	}
}

resource "aws_instance" "nat" {
	ami = data.aws_ami.amazon_linux_2023.id
	instance_type = "t3.micro"
	subnet_id = aws_subnet.public[0].id
	vpc_security_group_ids = [aws_security_group.nat_sg.id]
	associate_public_ip_address = true
	source_dest_check = false
	
	user_data = <<-EOF
		#!/bin/bash
		echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
		sysctl -p /etc/sysctl.conf
		IFACE=$(ip route | grep default | awk '{print $5}')
		iptables -t nat -A POSTROUTING -o $IFACE -j MASQUERADE
		EOF
	tags = {
		Name = "custom-nat-instance"
	}
}