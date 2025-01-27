# Movie Review Sentiment Analysis Lambda Function

This Lambda function analyzes movie reviews and predicts star ratings using a fine-tuned DistilBERT model.

## Local Testing with SAM CLI

### Prerequisites
- AWS SAM CLI installed
- Docker installed and running

### Local Testing with Container

We use a container-based approach for local testing to ensure consistency with the AWS Lambda environment.

1. Build and Start the API:
```bash
# Make the test script executable if needed
chmod +x local-test.sh

# Run the local test environment
./local-test.sh
```

This script will:
- Build the Lambda function using SAM with container support
- Start a local API endpoint with warm containers
- Keep the containers warm for faster testing

2. Test the API with curl (in a different terminal):
```bash
curl -X POST \
  http://127.0.0.1:3000/predict \
  -H 'Content-Type: application/json' \
  -d '{"review": "This movie was absolutely fantastic!"}'
```

### Environment Variables
The function uses the following environment variables:
- `MODEL_PATH`: Path to the model files (default: 'model/')

### Project Structure
```
.
├── app.py                 # Lambda handler
├── inference.py           # Model interface
├── requirements.txt       # Python dependencies
├── template.yaml         # SAM template
└── model/               # Model files
    ├── config.json
    ├── model.safetensors
    ├── special_tokens_map.json
    ├── tokenizer_config.json
    └── vocab.txt
```

## API Response Format
```json
{
  "star_rating": 5.0,
  "star_rating_text": "★★★★★",
  "confidence_score": 0.95
}
