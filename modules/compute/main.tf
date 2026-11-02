#left off here

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-launch-template-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_security_group_id]
  }

  user_data = base64encode(<<-EOF
	#!/bin/bash
	dnf update -y
	dnf install -y httpd
	systemctl start httpd
	TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
	AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN http://169.254.169/latest/meta-data/placement/availability-zone")
	INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
	echo "<h1>AWS Multi-AZ Infrastructure Running</h1><p><b>Instance ID:</b> $INSTANCE_ID</p><p><b>Availability Zone:</b> $AZ</p>" > /var/www/html/index.html
	EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-private-instance"
    }
  }
}


resource "aws_autoscaling_group" "app_asg" {
  name                = "app-asg-multi-az"
  vpc_zone_identifier = var.private_app_subnet_ids
  target_groups_arns  = [var.target_group_arn]

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                = "Name"
    value              = "app-asg-worker"
    propagae_at_launch = true
  }
}