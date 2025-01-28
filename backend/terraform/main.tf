# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Lambda Function using container image
resource "aws_lambda_function" "predict_rating" {
  function_name = "cinecriticpal-predict-rating"
  role         = aws_iam_role.lambda_exec.arn
  timeout      = 30
  memory_size  = 1024
  
  package_type = "Image"
  image_uri    = var.ecr_repository_url
  
  ephemeral_storage {
    size = 512
  }

  environment {
    variables = {
      MODEL_PATH = "model/"
    }
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "cinecriticpal_predict_rating_role"
  description = "IAM role for the CineCriticPal predict rating Lambda function"

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

  tags = {
    Environment = var.environment
    Project     = "CineCriticPal"
  }
}

# Lambda Execution Policy
resource "aws_iam_role_policy" "lambda_exec_policy" {
  name = "cinecriticpal_predict_rating_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "*"
      }
    ]
  })
}

# API Gateway for Lambda
resource "aws_apigatewayv2_api" "sentiment_api" {
  name          = "sentiment_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "predict_rating_integration" {
  api_id           = aws_apigatewayv2_api.sentiment_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.predict_rating.invoke_arn
}

resource "aws_apigatewayv2_route" "sentiment_route" {
  api_id    = aws_apigatewayv2_api.sentiment_api.id
  route_key = "POST /predict"
  target    = "integrations/${aws_apigatewayv2_integration.predict_rating_integration.id}"
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
  function_name = aws_lambda_function.predict_rating.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.sentiment_api.execution_arn}/*/*"
}
