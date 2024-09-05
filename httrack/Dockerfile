# Use Ubuntu as the base image
FROM ubuntu:20.04

# Set environment variables to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install httrack
RUN apt-get update && \
    apt-get install -y httrack && \
    apt-get clean

# Create a directory to store the scraped website
RUN mkdir /scraped-site

# Set the working directory
WORKDIR /scraped-site

# Define the entrypoint to run httrack when the container starts
ENTRYPOINT ["httrack"]
