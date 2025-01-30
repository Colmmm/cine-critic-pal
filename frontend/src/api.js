import axios from 'axios';

// The API endpoint will be provided by AWS Amplify during deployment
// For local development, we'll use environment variables
const API_BASE_URL = process.env.REACT_APP_API_ENDPOINT || 'http://localhost:3000';

export const submitReview = async (reviewText) => {
  try {
    const response = await axios.post(`${API_BASE_URL}/predict`, {
      review: reviewText
    });
    
    if (response.data && response.data.rating) {
      return {
        rating: response.data.rating
      };
    }
    
    throw new Error('Invalid response format');
  } catch (error) {
    console.error('API Error:', error);
    throw error;
  }
};
