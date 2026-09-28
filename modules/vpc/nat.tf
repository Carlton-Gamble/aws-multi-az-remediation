#Left off here
#look for nat.tf sec

data "aws_ami" "amazon_linux_2023" {
	most_recent = true
	owners = ["amazon"]

	filters {
	name = "name"
	values = ["al2023-ami-2023.*-x86_64"]
	}
}