# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Lambda Function for Sentiment Analysis
resource "aws_lambda_function" "sentiment_analysis" {
  function_name    = "sentiment_analysis"
  runtime         = "python3.9"
  handler         = "app.lambda_handler"
  role           = aws_iam_role.lambda_exec.arn
  filename        = "${path.module}/../lambda/sentiment_analysis/sentiment_analysis.zip"
  timeout         = 30
  memory_size     = 1024
  ephemeral_storage {
    size = 512
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach Basic Execution Policy to Lambda
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# API Gateway for Lambda
resource "aws_apigatewayv2_api" "sentiment_api" {
  name          = "sentiment_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "sentiment_integration" {
  api_id           = aws_apigatewayv2_api.sentiment_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.sentiment_analysis.invoke_arn
}

resource "aws_apigatewayv2_route" "sentiment_route" {
  api_id    = aws_apigatewayv2_api.sentiment_api.id
  route_key = "POST /predict"
  target    = "integrations/${aws_apigatewayv2_integration.sentiment_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.sentiment_api.id
  name        = "dev"
  auto_deploy = true
}

# AWS Amplify for Frontend
resource "aws_amplify_app" "frontend_app" {
  name                = "cinecriticpal-frontend"
  repository          = var.github_repository
  oauth_token         = var.github_oauth_token
  enable_auto_branch_creation = true

  environment_variables = {
    ENV = "production"
  }
}

resource "aws_amplify_branch" "frontend_branch" {
  app_id      = aws_amplify_app.frontend_app.id
  branch_name = "main" # Replace with your frontend branch name
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sentiment_analysis.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.sentiment_api.execution_arn}/*/*"
}
