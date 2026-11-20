#1. Zero-Trust Quarantine Security Group (No Ingress, No Egress)
resource "aws_security_group" "quarantine_sg" {
  name        = "quarantine-security-group"
  description = "Isolated security group for compromised EC2 instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "quarantine-sg"
  }
}

# 2. IAM Role & Policy for Lambda Execution
resource "aws_iam_role" "lambda_remediation_role" {
  name = "guardduty-remediation-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "lambda_remediation_policy" {
  name        = "guardduty-remediation-policy"
  description = "Allows Lambda to isolate instances and write CloudWatch logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:ModifyInstanceAttribute",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_remediation_role.name
  policy_arn = aws_iam_policy.lambda_remediation_policy.arn
}

# 3. Package Python Remediation Code
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/remediation_lambda.zip"

  source {
    content  = <<-PYTHON
      import boto3
      import os

      ec2 = boto3.client('ec2')
      QUARANTINE_SG = os.environ['QUARANTINE_SG_ID']

      def lambda_handler(event, context):
          print("GuardDuty Finding Event Received:", event)
          try:
              detail = event.get('detail', {})
              resource = detail.get('resource', {})
              instance_details = resource.get('instanceDetails', {})
              instance_id = instance_details.get('instanceId')

              if instance_id:
                  print(f"Isolating compromised instance: {instance_id}")
                  ec2.modify_instance_attribute(
                      InstanceId=instance_id,
                      Groups=[QUARANTINE_SG]
                  )
                  print(f"Successfully attached Quarantine SG {QUARANTINE_SG} to {instance_id}")
              else:
                  print("No Instance ID found in GuardDuty event payload.")
          except Exception as e:
              print(f"Error executing remediation: {str(e)}")
              raise e
    PYTHON
    filename = "index.py"
  }
}

# 4. AWS Lambda Function Resource
resource "aws_lambda_function" "remediation_fn" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "guardduty-auto-remediation"
  role             = aws_iam_role.lambda_remediation_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.11"

  environment {
    variables = {
      QUARANTINE_SG_ID = aws_security_group.quarantine_sg.id
    }
  }

  tags = {
    Name = "guardduty-remediation-lambda"
  }
}

# 5. EventBridge Rule to Capture GuardDuty Findings
resource "aws_cloudwatch_event_rule" "guardduty_finding_rule" {
  name        = "guardduty-threat-detected"
  description = "Triggers Lambda remediation when GuardDuty generates a finding"

  event_pattern = jsonencode({
    source      = ["aws.guardduty", "custom.guardduty"]
    detail-type = ["GuardDuty Finding"]
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.guardduty_finding_rule.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.remediation_fn.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.remediation_fn.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.guardduty_finding_rule.arn
}
