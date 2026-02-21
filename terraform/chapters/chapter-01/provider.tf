provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  # By default, Terraform uses Application Default Credentials (ADC).
  # If you have set up impersonation via gcloud, it will use that identity.
}
