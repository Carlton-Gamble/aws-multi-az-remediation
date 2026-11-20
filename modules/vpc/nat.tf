data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_security_group" "nat_sg" {
  name        = "nat-instance-sg"
  description = "Allow inbound traffic from private subnets for NAT outbound routing"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nat-instance-sg"
  }
}

resource "aws_instance" "nat" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.nat_sg.id]
  associate_public_ip_address = true
  source_dest_check           = false
  user_data_replace_on_change = true

  user_data = <<-EOF
              #!/bin/bash
              dnf install -y nftables
              sysctl -w net.ipv4.ip_forward=1
              echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-nat.conf
              IFACE=$(ip route | grep default | awk '{print $5}')
              nft add table ip nat
              nft 'add chain ip nat postrouting { type nat hook postrouting priority 100 ; }'
              nft add rule ip nat postrouting oifname "$IFACE" masquerade
              EOF

  tags = {
    Name = "custom-nat-instance"
  }
}