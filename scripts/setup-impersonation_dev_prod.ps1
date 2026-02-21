param (
    [Parameter(Mandatory=$true)]
    [string]$ProjectIdDev,
    [Parameter(Mandatory=$true)]
    [string]$ProjectIdProd
)

# 1. Force Authentication
Write-Host "--- Authentication Required ---" -ForegroundColor Yellow
Write-Host "Logging in to ensure active session..." -ForegroundColor Cyan
gcloud auth login --no-launch-browser

Write-Host "`nLogging in for Application Default Credentials (ADC)..." -ForegroundColor Cyan
gcloud auth application-default login --no-launch-browser

$UserEmail = gcloud config get-value account
Write-Host "`nAuthenticated as: $UserEmail" -ForegroundColor Green

function Setup-Project {
    param(
        [string]$ProjId,
        [string]$UserEmail
    )
    
    $SaName = "terraform-sa"
    $SaEmail = "${SaName}@${ProjId}.iam.gserviceaccount.com"

    Write-Host "`n--- Setting up project: $ProjId ---" -ForegroundColor Cyan
    
    # Verify project access
    $ProjectExists = gcloud projects describe $ProjId 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Project '$ProjId' not found or no permission to access it." -ForegroundColor Red
        return
    }

    gcloud config set project "$ProjId"
    gcloud auth application-default set-quota-project "$ProjId"

    # 1. Create Service Account
    Write-Host "Creating Service Account: $SaName" -ForegroundColor Cyan
    gcloud iam service-accounts create "$SaName" `
        --description="Terraform Service Account" `
        --display-name="Terraform SA" 2>$null

    # 2. Grant Project Editor to the SA
    Write-Host "Granting Editor role to the Service Account..." -ForegroundColor Cyan
    gcloud projects add-iam-policy-binding "$ProjId" `
        --member="serviceAccount:$SaEmail" `
        --role="roles/editor" --quiet

    # 3. Grant Impersonation permission to the current user
    Write-Host "Granting Impersonation role to: $UserEmail" -ForegroundColor Cyan
    gcloud iam service-accounts add-iam-policy-binding "$SaEmail" `
        --member="user:$UserEmail" `
        --role="roles/iam.serviceAccountTokenCreator" --quiet
}

# Setup Dev Project
Setup-Project -ProjId $ProjectIdDev -UserEmail $UserEmail

# Setup Prod Project
Setup-Project -ProjId $ProjectIdProd -UserEmail $UserEmail

Write-Host "`n----------------------------------------------------------" -ForegroundColor Green
Write-Host "Setup Complete for both environments!" -ForegroundColor Green
Write-Host "Verified projects: $ProjectIdDev, $ProjectIdProd" -ForegroundColor Green
Write-Host "----------------------------------------------------------" -ForegroundColor Green
