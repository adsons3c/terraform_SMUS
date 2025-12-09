terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.19.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.64.0"
    }
  }
}