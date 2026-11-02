variable "vpc_id" {
  type        = string
  description = "ID of the custome VPC"
}

resource "aws_guardduty_detector" "gd" {
  enable = true
}

resource "aws_security" "quarantine_sg" {
  name        = "quarantine-security-group"
  description = "Isolated security group for compromised EC2 instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "quarantine-sg"
  }
}

resource "aws_iam_role" "lambda_remediation_role" {
  name = "guardduty-remediation-lambda-role"

  assume_role_policy = jsonencode({
    version = "2012-10-17"
    Statement = [{
      Action   = "sts.AssumeRole"
      Effect   = "Allow"
      Pricipal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

