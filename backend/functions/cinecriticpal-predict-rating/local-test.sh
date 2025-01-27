#!/bin/bash

# Exit on error
set -e

echo "Building Lambda function with SAM..."
sam build --use-container --skip-pull-image

echo "Starting local API..."
sam local start-api --warm-containers EAGER

# The API will be available at http://127.0.0.1:3000/predict
# Use Ctrl+C to stop the API
