provider "aws" {
  region  = "ap-south-1" # Don't change the region
}

 terraform {
  backend "s3" {
    bucket = "467.devops.candidate.exam"
    key    = "devexam6"
    region = "ap-south-1"
  }
}