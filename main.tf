# Public Subnet
resource "aws_subnet" "PublicSubnet" {
  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "PublicSubnet"
  }
}

# Private Subnet
resource "aws_subnet" "PrivateSubnet" {
  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "PrivateSubnet"
  }
}

# Route Tables
resource "aws_route_table" "PublicRT" {
  vpc_id = data.aws_vpc.vpc.id
}

resource "aws_route_table" "PrivateRT" {
  vpc_id = data.aws_vpc.vpc.id
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "PublicToPublic" {
  subnet_id      = aws_subnet.PublicSubnet.id
  route_table_id = aws_route_table.PublicRT.id
  depends_on     = [aws_subnet.PublicSubnet, aws_route_table.PublicRT]
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "PrivateToPrivate" {
  subnet_id      = aws_subnet.PrivateSubnet.id
  route_table_id = aws_route_table.PrivateRT.id
  depends_on     = [aws_subnet.PrivateSubnet, aws_route_table.PrivateRT]
}

# Create Route in Public Route Table (if using IGW)
resource "aws_route" "RouteInPublicRT_TO_IGW" {
  route_table_id         = aws_route_table.PublicRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_nat_gateway.nat.id 
  depends_on             = [aws_route_table.PublicRT]
}

# Create Route in Private Route Table to NAT Gateway
resource "aws_route" "RouteInPrivateRT_TO_NATGW" {
  route_table_id         = aws_route_table.PrivateRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_nat_gateway.nat.id
  create_before_destroy  = true  
}


# Security Group
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
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Lambda function setup
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
