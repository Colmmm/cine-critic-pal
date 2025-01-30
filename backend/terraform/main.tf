# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Call all other configurations (automatically detected)
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
