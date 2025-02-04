


#public Subnet
resource "aws_subnet" "PublicSubnet" {
  vpc_id = data.aws_vpc.vpc.id
  cidr_block = "10.0.100.0/24"

  tags = {
    Name = "PublicSubnet"
  }
}
#Private Subnet
resource "aws_subnet" "PrivateSubnet" {
  vpc_id = data.aws_vpc.vpc.id
  cidr_block = "10.0.110.0/24"

  tags = {
    Name = "PrivateSubnet"
  }
}

#Public route table 
resource "aws_route_table" "PublicRT" {
  vpc_id = data.aws_vpc.vpc.id
  }

#Private route table 
resource "aws_route_table" "PrivateRT" {
  vpc_id = data.aws_vpc.vpc.id
  }

# route table association for public
resource "aws_route_table_association" "PublicToPublic" {
  subnet_id      = aws_subnet.PublicSubnet.id
  route_table_id = aws_route_table.PublicRT.id
}

# route table association for private
resource "aws_route_table_association" "PrivateToPrivate" {
  subnet_id      = aws_subnet.PrivateSubnet.id
  route_table_id = aws_route_table.PrivateRT.id
}

resource "aws_route" "RouteInPublicRT_TO_IGW" {
  route_table_id            = aws_route_table.PublicRT.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                 = data.aws_nat_gateway.nat.id
  depends_on                = [aws_route_table.PublicRT]

}

resource "aws_route" "RouteInPrivateRT_TO_NATGW" {
  route_table_id            = aws_route_table.PrivateRT.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = data.aws_nat_gateway.nat.id
  depends_on                = [aws_route_table.PrivateRT]
}

#security group
resource "aws_security_group" "SG" {
  name        = "SG"
  description = " SG to alllow traffic from the VPC"
  vpc_id = data.aws_vpc.vpc.id
  depends_on = [
    data.aws_vpc.vpc
  ]

 
#outbound access
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }
}

#creating zip of lambda file
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda.zip"
}

#lambda function configuration
resource "aws_lambda_function" "lambda_handler" {
  filename      = data.archive_file.lambda.output_path
  function_name = "lambda_handler"
  role          =  data.aws_iam_role.lambda.arn
  handler       = "lambda.lambda_handler"
  runtime       = "python3.9"
  source_code_hash = data.archive_file.lambda.output_base64sha256

}






