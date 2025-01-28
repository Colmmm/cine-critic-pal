# AWS region
variable "aws_region" {
  description = "AWS region to deploy resources in"
  default     = "eu-west-2"
}

# ECR repository URL (including tag)
variable "ecr_repository_url" {
  description = "Full ECR repository URL with tag for the Lambda container image"
  type        = string
  sensitive   = true
}

# Environment
variable "environment" {
  description = "Environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

# GitHub OAuth token for Amplify
variable "github_oauth_token" {
  description = "GitHub token to enable Amplify access to the repository"
  type        = string
}

# GitHub repository URL
variable "github_repository" {
  description = "GitHub repository URL for the frontend application"
  type        = string
  default     = "https://github.com/Colmmm/cine-critic-pal"
}
