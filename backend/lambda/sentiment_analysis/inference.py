"""
Movie Review Sentiment Analysis Model Interface

This module provides functionality to analyze movie reviews and predict star ratings
using a fine-tuned DistilBERT model. It converts model outputs to human-readable
star ratings and provides confidence scores for predictions.
"""

from transformers import pipeline, DistilBertForSequenceClassification, DistilBertTokenizer

class MovieReviewAnalyzer:
    """Handles movie review sentiment analysis and star rating prediction."""
    
    def __init__(self, model_path='model/'):
        """
        Initialize the movie review analyzer with a pre-trained model.
        
        Args:
            model_path (str): Path to the model files directory
        """
        # Load the fine-tuned classification model and tokenizer
        self.model = DistilBertForSequenceClassification.from_pretrained(model_path)
        self.tokenizer = DistilBertTokenizer.from_pretrained(model_path)
        
        # Set up the classification pipeline
        self.classifier = pipeline('text-classification', 
                                 model=self.model, 
                                 tokenizer=self.tokenizer)
        
        # Mapping from model labels to star ratings
        self.label_to_stars = {
            'LABEL_0': '½',
            'LABEL_1': '★',
            'LABEL_2': '★½',
            'LABEL_3': '★★',
            'LABEL_4': '★★½',
            'LABEL_5': '★★★',
            'LABEL_6': '★★★½',
            'LABEL_7': '★★★★',
            'LABEL_8': '★★★★½',
            'LABEL_9': '★★★★★'
        }
        
        # Mapping for converting star symbols to numerical values
        self.rating_map = {'★': 1, '½': 0.5}
    
    def _convert_label_to_stars(self, label):
        """
        Convert model label to star rating text.
        
        Args:
            label (str): Model label (e.g., 'LABEL_0' to 'LABEL_9')
            
        Returns:
            str: Star rating in text format (e.g., '★★★½')
        """
        return self.label_to_stars.get(label, 'Unknown')
    
    def _normalize_rating(self, star_rating):
        """
        Convert star rating text to numerical score.
        
        Args:
            star_rating (str): Star rating in text format (e.g., '★★★½')
            
        Returns:
            float: Normalized rating score (0.5-5.0)
        """
        return sum(self.rating_map[char] 
                  for char in star_rating 
                  if char in self.rating_map)
    
    def predict_rating(self, review_text):
        """
        Predict star rating for a movie review.
        
        Args:
            review_text (str): The movie review text to analyze
            
        Returns:
            dict: Prediction results containing:
                - star_rating (float): Numerical rating (0.5-5.0)
                - star_rating_text (str): Rating in star format (e.g., '★★★½')
                - confidence_score (float): Model's confidence in prediction
        """
        # Get model prediction
        prediction = self.classifier(review_text)[0]
        label = prediction['label']
        confidence = prediction['score']
        
        # Convert to star rating format
        star_rating_text = self._convert_label_to_stars(label)
        star_rating = self._normalize_rating(star_rating_text)
        
        return {
            'star_rating': star_rating,
            'star_rating_text': star_rating_text,
            'confidence_score': confidence
        }
