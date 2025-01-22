# AWS region
variable "aws_region" {
  description = "AWS region to deploy resources in"
  default     = "us-east-1" # Change this to your desired default region
}

# GitHub OAuth token for Amplify
variable "github_oauth_token" {
  description = "GitHub token to enable Amplify access to the repository"
  type        = string
}
