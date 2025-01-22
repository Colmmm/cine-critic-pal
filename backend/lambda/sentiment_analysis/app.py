"""
AWS Lambda handler for movie review sentiment analysis.
Processes incoming review text and returns predicted star ratings.
"""

import json
import logging
from inference import MovieReviewAnalyzer

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize the analyzer outside the handler for reuse across invocations
try:
    analyzer = MovieReviewAnalyzer(model_path='model/')
    logger.info("Successfully initialized MovieReviewAnalyzer")
except Exception as e:
    logger.error(f"Failed to initialize MovieReviewAnalyzer: {str(e)}")
    raise

def create_response(status_code, body):
    """Create a standardized API response"""
    return {
        'statusCode': status_code,
        'body': json.dumps(body),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }

def lambda_handler(event, context):
    """
    Handle incoming movie review analysis requests.
    
    Args:
        event (dict): API Gateway event containing the review text
        context (object): Lambda context
        
    Returns:
        dict: API Gateway response containing the predicted rating
    """
    try:
        # Parse and validate the request body
        body = json.loads(event['body'])
        review_text = body.get('review')
        
        if not review_text:
            logger.warning("Received request with missing review text")
            return create_response(400, {
                'error': 'Missing review text in request body'
            })
        
        # Log the incoming review (truncated for privacy)
        logger.info(f"Processing review: {review_text[:100]}...")
        
        # Get prediction from the model
        prediction = analyzer.predict_rating(review_text)
        logger.info(f"Generated prediction: {prediction}")
        
        return create_response(200, prediction)
        
    except json.JSONDecodeError:
        logger.error("Failed to parse request body as JSON")
        return create_response(400, {
            'error': 'Invalid JSON in request body'
        })
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        return create_response(500, {
            'error': 'Internal server error'
        })
