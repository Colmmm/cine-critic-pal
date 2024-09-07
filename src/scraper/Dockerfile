FROM python:3.9-slim

# Install system dependencies required by Playwright
RUN apt-get update && apt-get install -y \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libxcomposite1 \
    libxrandr2 \
    libxdamage1 \
    libxkbcommon0 \
    libgbm1 \
    libpango1.0-0 \
    libgtk-3-0 \
    wget \
    libasound2 \
    libnspr4

# Set the working directory
WORKDIR /app

# Copy the scraper dir to app 
COPY src/scraper/ /app/scraper

# Install dependencies
#RUN pip install --no-cache-dir -r scraper/requirements.txt
RUN pip install -r scraper/requirements.txt

# Install Playwright browsers
RUN playwright install --with-deps

# Set the entry point for the scraper
ENTRYPOINT ["python", "/app/scraper/scrape.py"]

