# setup-impersonation.ps1
# This script sets up Service Account Impersonation for Terraform on Windows.
# Usage: .\setup-impersonation.ps1 agentic-experiments-472704

param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectId
)

$SaName = "terraform-sa"
$SaEmail = "${SaName}@${ProjectId}.iam.gserviceaccount.com"

Write-Host "Setting up project: $ProjectId" -ForegroundColor Cyan
gcloud config set project "$ProjectId"

# 1. Create Service Account
Write-Host "Creating Service Account: $SaName" -ForegroundColor Cyan
gcloud iam service-accounts create "$SaName" `
    --description="Terraform Service Account" `
    --display-name="Terraform SA"

# 2. Grant Project Editor to the SA
Write-Host "Granting Editor role to the Service Account..." -ForegroundColor Cyan
gcloud projects add-iam-policy-binding "$ProjectId" `
    --member="serviceAccount:$SaEmail" `
    --role="roles/editor"

# 3. Grant Impersonation permission to the current user
$UserEmail = gcloud config get-value account
Write-Host "Granting Impersonation role to: $UserEmail" -ForegroundColor Cyan
gcloud iam service-accounts add-iam-policy-binding "$SaEmail" `
    --member="user:$UserEmail" `
    --role="roles/iam.serviceAccountTokenCreator"

# 4. Login with Application Default Credentials
Write-Host "Logging in with Application Default Credentials..." -ForegroundColor Cyan
gcloud auth application-default login --no-launch-browser

Write-Host "----------------------------------------------------------" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "Update your terraform.tfvars with project_id = `"$ProjectId`"" -ForegroundColor Green
Write-Host "Then run: terraform init && terraform plan" -ForegroundColor Green
Write-Host "----------------------------------------------------------" -ForegroundColor Green
