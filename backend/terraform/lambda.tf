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