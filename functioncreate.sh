#!/bin/bash

# Create main.py with the sample function
cat << EOF > main.py
def hello_world(request):
    return 'Hello, DevFest Workshop!'
EOF

# Create an empty requirements.txt
touch requirements.txt

# Set your project ID
PROJECT_ID=$(gcloud config get-value project)

# Enable necessary APIs
gcloud services enable cloudfunctions.googleapis.com cloudbuild.googleapis.com

# Deploy the function
gcloud functions deploy devfest-function \
  --runtime python39 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point hello_world \
  --region us-central1

# Get the URL of the deployed function
gcloud functions describe devfest-function --region us-central1 --format='value(httpsTrigger.url)'