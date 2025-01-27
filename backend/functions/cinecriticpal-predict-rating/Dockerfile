# Stage 1: Dependency installation
FROM public.ecr.aws/lambda/python:3.9 AS build

# Install dependencies
WORKDIR /tmp
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt -t /tmp/lambda_dependencies

# Stage 2: Build the runtime image
FROM public.ecr.aws/lambda/python:3.9

# Set working directory inside the Lambda runtime
WORKDIR /var/task

# Copy application code
COPY app.py .
COPY inference.py .
COPY model/ ./model/

# Copy only the installed dependencies from the previous stage
COPY --from=build /tmp/lambda_dependencies ./

# Lambda entry point
CMD ["app.lambda_handler"]