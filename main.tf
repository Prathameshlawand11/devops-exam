# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name               = "lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# IAM Policy for Lambda Role
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:TerminateInstances",
          "ec2:DeleteTags",  # Permissions related to EC2
          "ec2:DescribeSecurityGroups",  # Other EC2 related permissions
          "ec2:DescribeSubnets", 
          "ec2:DescribeVpcs",
          "ec2:CreateTags",
          "ec2:ModifyInstanceAttribute",
          "ec2:RunInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"  # Example permissions for S3
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"  # Permissions for CloudWatch Logs
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Public Subnet
resource "aws_subnet" "PublicSubnet" {
  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = "10.0.100.0/24"

  tags = {
    Name = "PublicSubnet"
  }
}

# Private Subnet
resource "aws_subnet" "PrivateSubnet" {
  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = "10.0.110.0/24"

  tags = {
    Name = "PrivateSubnet"
  }
}

# Public Route Table
resource "aws_route_table" "PublicRT" {
  vpc_id = data.aws_vpc.vpc.id
}

# Private Route Table
resource "aws_route_table" "PrivateRT" {
  vpc_id = data.aws_vpc.vpc.id
}

# Route Table Association for Public
resource "aws_route_table_association" "PublicToPublic" {
  subnet_id      = aws_subnet.PublicSubnet.id
  route_table_id = aws_route_table.PublicRT.id
}

# Route Table Association for Private
resource "aws_route_table_association" "PrivateToPrivate" {
  subnet_id      = aws_subnet.PrivateSubnet.id
  route_table_id = aws_route_table.PrivateRT.id
}

resource "aws_route" "RouteInPublicRT_TO_IGW" {
  route_table_id         = aws_route_table.PublicRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_nat_gateway.nat.id
  depends_on             = [aws_route_table.PublicRT]
}

resource "aws_route" "RouteInPrivateRT_TO_NATGW" {
  route_table_id         = aws_route_table.PrivateRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_nat_gateway.nat.id
  depends_on             = [aws_route_table.PrivateRT]
}

# Security Group
resource "aws_security_group" "SG" {
  name        = "SG"
  description = "SG to allow traffic from the VPC"
  vpc_id      = data.aws_vpc.vpc.id
  depends_on  = [data.aws_vpc.vpc]

  # Outbound Access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating zip of Lambda file
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda.zip"
}

# Lambda Function Configuration
resource "aws_lambda_function" "lambda_handler" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "lambda_handler"
  role             = aws_iam_role.lambda.arn
  handler          = "lambda.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda.output_base64sha256
}
