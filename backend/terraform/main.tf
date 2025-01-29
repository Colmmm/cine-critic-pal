# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Lambda Function using container image
resource "aws_lambda_function" "predict_rating" {
  function_name = "cinecriticpal-predict-rating"
  role         = aws_iam_role.lambda_exec.arn
  timeout      = 300
  memory_size  = 3008
  
  package_type = "Image"
  image_uri    = var.ecr_repository_url
  
  ephemeral_storage {
    size = 1024
  }

  environment {
    variables = {
      MODEL_PATH = "model/"
    }
  }

  publish = true
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
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:EnableReplication*",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration"
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

  cors_configuration {
    allow_headers = ["Content-Type"]
    allow_methods = ["POST"]
    allow_origins = ["*"]
    max_age      = 300
  }
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

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.sentiment_api.name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.predict_rating.function_name}"
  retention_in_days = 7
}

# IAM Role for API Gateway Logging
resource "aws_iam_role" "api_gateway_logging" {
  name = "api_gateway_cloudwatch_logging"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "api_gateway_logging" {
  name = "api_gateway_logging_policy"
  role = aws_iam_role.api_gateway_logging.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.api_logs.arn}:*"
      }
    ]
  })
}

# API Gateway Stage with Logging
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.sentiment_api.id
  name        = "dev"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip            = "$context.identity.sourceIp"
      requestTime   = "$context.requestTime"
      httpMethod    = "$context.httpMethod"
      routeKey      = "$context.routeKey"
      status        = "$context.status"
      protocol      = "$context.protocol"
      responseLength = "$context.responseLength"
      integrationError = "$context.integrationErrorMessage"
      integrationStatus = "$context.integrationStatus"
    })
  }

  default_route_settings {
    detailed_metrics_enabled = true
    data_trace_enabled      = true
    logging_level           = "INFO"
    throttling_burst_limit  = 5000
    throttling_rate_limit   = 10000
  }
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
