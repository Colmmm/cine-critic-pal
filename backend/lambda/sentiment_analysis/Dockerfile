FROM public.ecr.aws/lambda/python:3.9

# Install system dependencies
RUN yum install -y gcc-c++

# Copy requirements first to leverage Docker cache
COPY requirements.txt ${LAMBDA_TASK_ROOT}
RUN pip install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

# Copy function code and model
COPY . ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler
CMD [ "app.lambda_handler" ]
