# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Install system dependencies for Playwright and other packages
RUN apt-get update && apt-get install -y \
    wget \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libxcomposite1 \
    libxrandr2 \
    libgbm1 \
    libgtk-3-0 \
    libxdamage1 \
    libasound2 \
    libpangocairo-1.0-0 \
    libpango-1.0-0 \
    libffi-dev \
    libgdk-pixbuf2.0-0 \
    && apt-get clean

# Copy only the requirements file to leverage caching
COPY ./src/scraper/requirements.txt /app/

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Install Playwright and browsers (Chromium)
RUN pip install playwright \
    && playwright install --with-deps chromium  # Install Chromium with dependencies

# Copy the rest of the application code
COPY ./src/scraper /app/scraper

# Set the default command to run the scraper
CMD ["python", "/app/scraper/scrape.py"]
