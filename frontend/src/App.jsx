import React, { useState } from 'react';
import { TextField, Button, Container, Typography, Box, CircularProgress } from '@mui/material';
import { submitReview } from './api';

function App() {
  const [review, setReview] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const response = await submitReview(review);
      setResult(response);
    } catch (error) {
      console.error('Error submitting review:', error);
      setResult({ error: 'Failed to submit review' });
    }
    setLoading(false);
  };

  return (
    <Container maxWidth="md">
      <Box sx={{ my: 4 }}>
        <Typography variant="h4" component="h1" gutterBottom align="center">
          CineCriticPal
        </Typography>
        <Typography variant="subtitle1" gutterBottom align="center">
          Don’t overthink your movie review ratings—CineCriticPal has you covered.
        </Typography>
        
        <Box component="form" onSubmit={handleSubmit} className="review-form">
          <TextField
            fullWidth
            multiline
            rows={4}
            variant="outlined"
            label="Your Movie Review"
            value={review}
            onChange={(e) => setReview(e.target.value)}
            disabled={loading}
            placeholder="Write your movie review here..."
          />
          <Button
            type="submit"
            variant="contained"
            color="primary"
            fullWidth
            sx={{ mt: 2 }}
            disabled={loading || !review.trim()}
          >
            {loading ? (
              <>
                <CircularProgress size={24} sx={{ mr: 1 }} color="inherit" />
                Analyzing...
              </>
            ) : (
              'Get Rating'
            )}
          </Button>
        </Box>

        {result && (
          <Box className="result-section">
            <Typography variant="h6" gutterBottom>
              Analysis Result
            </Typography>
            {result.error ? (
              <Typography color="error">{result.error}</Typography>
            ) : (
              <Typography variant="body1">
                Predicted Rating: {result.rating}
              </Typography>
            )}
          </Box>
        )}
      </Box>
    </Container>
  );
}

export default App;
