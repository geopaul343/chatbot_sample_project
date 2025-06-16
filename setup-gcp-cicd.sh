#!/bin/bash

# Laennec AI Health Assistant - GCP CI/CD Setup Script
# This script sets up the required GCP services and configurations

set -e

# Configuration - REPLACE THESE WITH YOUR ACTUAL VALUES
PROJECT_ID="YOUR_PROJECT_ID"
GITHUB_REPO_OWNER="YOUR_GITHUB_USERNAME"
GITHUB_REPO_NAME="YOUR_REPOSITORY_NAME"
SERVICE_ACCOUNT_NAME="laennec-cicd-sa"
BUCKET_NAME="chatbot_laennec_geo"

echo "🚀 Setting up GCP CI/CD for Laennec AI Health Assistant"
echo "Project ID: $PROJECT_ID"

# Step 1: Enable required APIs
echo "📡 Enabling required GCP APIs..."
gcloud services enable cloudbuild.googleapis.com \
  secretmanager.googleapis.com \
  storage.googleapis.com \
  androidpublisher.googleapis.com \
  --project=$PROJECT_ID

# Step 2: Create service account
echo "👤 Creating service account..."
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
  --description="Service account for Laennec AI CI/CD" \
  --display-name="Laennec CI/CD Service Account" \
  --project=$PROJECT_ID

# Step 3: Grant necessary permissions
echo "🔐 Granting permissions to service account..."
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/cloudbuild.builds.builder"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/secretmanager.secretAccessor"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/storage.objectAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/logging.logWriter"

# Step 4: Create storage bucket
echo "🪣 Creating storage bucket..."
gsutil mb -p $PROJECT_ID gs://$BUCKET_NAME 2>/dev/null || echo "Bucket already exists"

# Step 5: Set up secrets (placeholders - you need to add actual values)
echo "🔒 Setting up secrets in Secret Manager..."

echo "ℹ️  You need to manually add the following secrets:"
echo "   1. Android Keystore:"
echo "      gcloud secrets create android-keystore --project=$PROJECT_ID"
echo "      gcloud secrets versions add android-keystore --data-file=path/to/your/keystore.jks --project=$PROJECT_ID"
echo ""
echo "   2. Play Store Credentials:"
echo "      gcloud secrets create playstore-credentials --project=$PROJECT_ID"
echo "      gcloud secrets versions add playstore-credentials --data-file=path/to/your/play-console-key.json --project=$PROJECT_ID"

# Step 6: Create Cloud Build trigger
echo "⚙️  Creating Cloud Build trigger..."
gcloud builds triggers create github \
  --repo-name=$GITHUB_REPO_NAME \
  --repo-owner=$GITHUB_REPO_OWNER \
  --branch-pattern="^main$" \
  --build-config=cloudbuild.yaml \
  --name="laennec-ai-flutter-cicd" \
  --description="CI/CD for Laennec AI Health Assistant" \
  --service-account="projects/$PROJECT_ID/serviceAccounts/$SERVICE_ACCOUNT_EMAIL" \
  --substitutions="_BUCKET_NAME=$BUCKET_NAME,_VERSION_PREFIX=1.0.3" \
  --project=$PROJECT_ID

echo "✅ Setup complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Add your Android keystore to Secret Manager"
echo "2. Add your Play Store service account key to Secret Manager"
echo "3. Update the GitHub repository owner and name in cloudbuild-trigger.yaml"
echo "4. Connect your GitHub repository to Cloud Build"
echo "5. Test the pipeline by pushing to main branch"
echo ""
echo "🔗 Useful links:"
echo "- Cloud Build Console: https://console.cloud.google.com/cloud-build/builds?project=$PROJECT_ID"
echo "- Secret Manager: https://console.cloud.google.com/security/secret-manager?project=$PROJECT_ID"
echo "- Storage Bucket: https://console.cloud.google.com/storage/browser/$BUCKET_NAME?project=$PROJECT_ID" 