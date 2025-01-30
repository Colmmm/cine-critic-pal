# API Gateway for Lambda
resource "aws_apigatewayv2_api" "sentiment_api" {
  name          = "sentiment_api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = ["Content-Type"]
    allow_methods = ["POST"]
    allow_origins = ["*"]
    max_age       = 300
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
    throttling_burst_limit  = 5000
    throttling_rate_limit   = 10000
  }
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.predict_rating.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.sentiment_api.execution_arn}/*/*"
}
