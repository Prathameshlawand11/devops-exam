# Private Subnet
resource "aws_subnet" "PrivateSubnet" {
  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "PrivateSubnet"
  }
}

# Route Tables for Private Subnet
resource "aws_route_table" "PrivateRT" {
  vpc_id = data.aws_vpc.vpc.id
}

# Security Group (Adjust the rules according to your requirements)
resource "aws_security_group" "SG" {
  name        = "SG"
  description = "Security Group to allow traffic from the VPC"
  vpc_id      = data.aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust according to security requirements
  }
}


# Lambda Function Setup
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "lambda_handler" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "lambda_handler"
  role             = data.aws_iam_role.lambda.arn
  handler          = "lambda.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda.output_base64sha256
}

# Output Subnet ID
output "subnet_id" {
  value = aws_subnet.PrivateSubnet.id
}
