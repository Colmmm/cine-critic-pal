#!/bin/bash

# Exit on error
set -e

echo "Creating package directory..."
rm -rf package
mkdir -p package

echo "Installing dependencies..."
pip install -r requirements.txt --target ./package

echo "Copying source files..."
cp app.py package/
cp inference.py package/

echo "Copying model files..."
mkdir -p package/model
cp model/* package/model/

echo "Creating deployment package..."
cd package
zip -r ../sentiment_analysis.zip .

echo "Cleaning up..."
cd ..
rm -rf package

echo "Package created: sentiment_analysis.zip"
