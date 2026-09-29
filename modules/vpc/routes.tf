# Public Route Table

resource "aws_route_table" "public" {
	vpc_id = aws_vpc.main.id

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.gw.id
	}

	tags = {
		Name = "public-route-table"
	}
}

resource "aws_route_table_association" "public" {
	count = length(var.public_subnet_cidrs)
	subnet_id = aws_subnet.public[count.index].id
	route_table_id = aws_route_table.public.id
}

#Private Route Table
resource "aws_route_table" "private" {
	vpc_id = aws_vpc.main.id
	
	route {
		cidr_block = "0.0.0.0/0"
		network_interface_id = aws_instance.nat.primary_network_interface_id
	}

	tags = {
		Name = "Private-route-table"
	}
}

resource "aws_route_table_association" "private_app" {
	count = length(var.private_app_subnet_cidrs)
	subnet_id = aws_subnet.private_app[count.index].id
	route_table_id = aws_route_table.private.id
}