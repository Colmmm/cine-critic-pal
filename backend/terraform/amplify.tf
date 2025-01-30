resource "aws_amplify_app" "frontend_app" {
  name                        = "cinecriticpal-frontend"
  repository                  = var.github_repository
  oauth_token                 = var.github_oauth_token
  enable_auto_branch_creation = true

  environment_variables = {
    ENV = "production"
  }
}

resource "aws_amplify_branch" "frontend_branch" {
  app_id      = aws_amplify_app.frontend_app.id
  branch_name = "main"
}
