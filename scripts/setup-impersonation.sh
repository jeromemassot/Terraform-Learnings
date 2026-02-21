#!/bin/bash

# This script sets up Service Account Impersonation for Terraform.
# Based on Terraform for Google Cloud Essential Guide (Chapter 01).

if [ -z "$1" ]; then
    echo "Usage: ./setup-impersonation.sh <PROJECT_ID>"
    exit 1
fi

PROJECT_ID=$1
SA_NAME="terraform-sa"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Setting up project: $PROJECT_ID"
gcloud config set project "$PROJECT_ID"

# 1. Create Service Account
echo "Creating Service Account: $SA_NAME"
gcloud iam service-accounts create "$SA_NAME" \
    --description="Terraform Service Account" \
    --display-name="Terraform SA"

# 2. Grant Project Editor (or more granular roles) to the SA
echo "Granting Editor role to the Service Account"
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/editor"

# 3. Grant Impersonation permission to the current user
USER_EMAIL=$(gcloud config get-value account)
echo "Granting Impersonation role to: $USER_EMAIL"
gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL" \
    --member="user:$USER_EMAIL" \
    --role="roles/iam.serviceAccountTokenCreator"

# 4. Login with Application Default Credentials
echo "Logging in with Application Default Credentials..."
gcloud auth application-default login --no-launch-browser

echo "----------------------------------------------------------"
echo "Setup Complete!"
echo "Update your terraform.tfvars with project_id = \"$PROJECT_ID\""
echo "Then run: terraform init && terraform plan"
echo "----------------------------------------------------------"
