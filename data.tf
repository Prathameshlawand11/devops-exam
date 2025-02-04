data "aws_nat_gateway" "nat" {
  id = "nat-0a34a8efd5e420945"
}

data "aws_vpc" "vpc" {
  id = "vpc-06b326e20d7db55f9"
}

data "aws_iam_role" "lambda" {
  name = "DevOps-Candidate-Lambda-Role"
}
