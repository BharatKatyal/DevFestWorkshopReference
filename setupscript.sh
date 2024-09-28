#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to check if gcloud is installed
check_gcloud() {
    if ! command -v gcloud &> /dev/null; then
        echo "gcloud could not be found. Please install the Google Cloud SDK."
        exit 1
    fi
}

# Function to check if user is authenticated with gcloud
check_auth() {
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null; then
        echo "You are not authenticated with gcloud. Please run 'gcloud auth login'."
        exit 1
    fi
}

# Main setup function
setup() {
    # Set variables
    PROJECT_ID=$(gcloud config get-value project)
    SERVICE_ACCOUNT_NAME="github-actions-sa"
    SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
    KEY_FILE="service-account-key.json"
    REGION="us-central1"
    REPOSITORY_NAME="devfest-workshop-repo"

    echo "Setting up Google Cloud resources for project: ${PROJECT_ID}"

    # Enable necessary APIs
    echo "Enabling necessary APIs..."
    gcloud services enable run.googleapis.com cloudbuild.googleapis.com iam.googleapis.com artifactregistry.googleapis.com

    # Create Artifact Registry repository
    echo "Creating Artifact Registry repository..."
    gcloud artifacts repositories create $REPOSITORY_NAME \
        --repository-format=docker \
        --location=$REGION \
        --description="Docker repository for DevFest Workshop"

    # Create service account
    echo "Creating service account..."
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --display-name "GitHub Actions Service Account"

    # Assign roles to the service account
    echo "Assigning roles to the service account..."
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="roles/run.admin"
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="roles/storage.admin"
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="roles/iam.serviceAccountUser"
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="roles/artifactregistry.admin"

    # Create and download a JSON key for the service account
    echo "Creating and downloading service account key..."
    gcloud iam service-accounts keys create $KEY_FILE --iam-account=$SERVICE_ACCOUNT_EMAIL

    # Output the details
    echo "Setup complete! Use the following values for your GitHub secrets:"
    echo "GCP_PROJECT_ID: $PROJECT_ID"
    echo "GCP_SA_KEY: $(cat $KEY_FILE | base64 -w 0)"

    echo "Please add these as secrets in your GitHub repository."
    echo "After adding the secrets, you can delete the $KEY_FILE file from your local machine."
    
    echo "Artifact Registry repository '${REPOSITORY_NAME}' has been created in region '${REGION}'."
    echo "Update your GitHub Actions workflow to use: ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_NAME}/devfestworkshopfunction"
}

# Run the script
check_gcloud
check_auth
setup