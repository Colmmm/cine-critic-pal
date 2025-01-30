# API Gateway Endpoint
output "api_endpoint" {
  description = "The API Gateway endpoint for the sentiment analysis function"
  value       = "${aws_apigatewayv2_stage.default_stage.invoke_url}/predict"
}

# Amplify Frontend URL
output "amplify_frontend_url" {
  description = "The Amplify-hosted frontend application URL"
  value       = aws_amplify_app.frontend_app.default_domain
}
