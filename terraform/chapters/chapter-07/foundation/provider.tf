# Terraform Syntax: `terraform` block defines the version and providers required.
terraform {
  required_version = "~> 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.40"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
