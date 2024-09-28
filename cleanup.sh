    PROJECT_ID=$(gcloud config get-value project)
    SERVICE_ACCOUNT_NAME="github-actions-sa"
    SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
    REGION="us-central1"
    REPOSITORY_NAME="devfest-workshop-repo"
    SERVICE_NAME="devfestworkshopfunction"

    echo "Cleaning up Google Cloud resources for project: ${PROJECT_ID}"

    # Delete Cloud Run service
    echo "Deleting Cloud Run service..."
    gcloud run services delete $SERVICE_NAME --region=$REGION --quiet || true

    # Delete Artifact Registry repository
    echo "Deleting Artifact Registry repository..."
    gcloud artifacts repositories delete $REPOSITORY_NAME --location=$REGION --quiet || true

    # Remove IAM policy bindings
    echo "Removing IAM policy bindings..."
    gcloud projects remove-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="roles/run.admin" --quiet || true
    gcloud projects remove-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="roles/storage.admin" --quiet || true
    gcloud projects remove-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="roles/iam.serviceAccountUser" --quiet || true
    gcloud projects remove-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="roles/artifactregistry.admin" --quiet || true

    # Delete service account
    echo "Deleting service account..."
    gcloud iam service-accounts delete $SERVICE_ACCOUNT_EMAIL --quiet || true

    # Disable APIs (optional, uncomment if you want to disable the APIs)
    # echo "Disabling APIs..."
    # gcloud services disable run.googleapis.com cloudbuild.googleapis.com iam.googleapis.com artifactregistry.googleapis.com --quiet

    echo "Cleanup complete! The following resources have been removed (if they existed):"
    echo "- Cloud Run service: $SERVICE_NAME"
    echo "- Artifact Registry repository: $REPOSITORY_NAME"
    echo "- Service Account: $SERVICE_ACCOUNT_EMAIL"
    echo "- IAM policy bindings for the service account"
    echo ""
    echo "Note: APIs have not been disabled. If you want to disable them, uncomment the relevant lines in the script."