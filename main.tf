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

# Public route table
resource "aws_route_table" "PublicRT" {
  vpc_id = data.aws_vpc.vpc.id
}

# Private route table
resource "aws_route_table" "PrivateRT" {
  vpc_id = data.aws_vpc.vpc.id
}

# Route table association for public
resource "aws_route_table_association" "PublicToPublic" {
  subnet_id      = aws_subnet.PublicSubnet.id
  route_table_id = aws_route_table.PublicRT.id
}

# Route table association for private
resource "aws_route_table_association" "PrivateToPrivate" {
  subnet_id      = aws_subnet.PrivateSubnet.id
  route_table_id = aws_route_table.PrivateRT.id
}

# Route in Public RT to IGW (for Public Subnet)
resource "aws_route" "RouteInPublicRT_TO_IGW" {
  route_table_id         = aws_route_table.PublicRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.igw.id
}

# Route in Private RT to NAT GW (for Private Subnet)
resource "aws_route" "RouteInPrivateRT_TO_NATGW" {
  route_table_id         = aws_route_table.PrivateRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_nat_gateway.nat.id
}

# Security Group for Lambda
resource "aws_security_group" "SG" {
  name        = "SG"
  description = "SG to allow traffic from the VPC"
  vpc_id      = data.aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating zip of lambda file
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda.zip"
}

# Lambda function configuration
resource "aws_lambda_function" "lambda_handler" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "lambda_handler"
  role             = data.aws_iam_role.lambda.arn
  handler          = "lambda.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.PrivateSubnet.id]
    security_group_ids = [aws_security_group.SG.id]
  }
}

# Output the Private Subnet ID
output "subnet_id" {
  value = aws_subnet.PrivateSubnet.id
}
