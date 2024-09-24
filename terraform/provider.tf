terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.64"
    }
  }
  backend "s3" {
    bucket         = "tf-s3-step-1-pipeline"
    key            = "terraform.tfstate"
    dynamodb_table = "tf-dynamodb-step-1-pipeline"
    region         = "us-east-1"
  }
}
provider "aws" {
  region = "us-east-1"
}
