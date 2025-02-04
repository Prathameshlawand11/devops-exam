# Public Subnet
resource "aws_subnet" "PublicSubnet" {
  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "PublicSubnet"
  }
}

# Route Table for Public Subnet (Modify route for public access)
resource "aws_route_table" "PublicRT" {
  vpc_id = data.aws_vpc.vpc.id
}

# Adding default route for Public Subnet
resource "aws_route" "PublicRoute" {
  route_table_id         = aws_route_table.PublicRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.igw.id  # Ensure you have an Internet Gateway

  depends_on = [
    aws_subnet.PublicSubnet
  ]
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

# Lambda Function Setup (No Route Deletion)
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

# Output Subnet IDs
output "subnet_id" {
  value = aws_subnet.PublicSubnet.id
}
