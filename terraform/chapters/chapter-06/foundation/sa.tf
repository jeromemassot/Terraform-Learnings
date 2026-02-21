# CREATE CUSTOM SERVICE ACCOUNT
# This resource creates a specific identity for our infrastructure.
# It 'depends_on' the IAM API to ensure the service is enabled before creation.
resource "google_service_account" "this" {
  depends_on   = [google_project_service.this["iam"]]
  account_id   = var.sa_name
  display_name = "${var.sa_name} Service Account"
}

# ASSIGN IAM ROLES TO THE SERVICE ACCOUNT
# This block iterates through the list of roles defined in 'var.roles'.
# KEY INSIGHT: We don't hardcode the service account email. Terraform automatically 
# retrieves the 'email' attribute from the 'google_service_account.this' resource 
# created above. This ensures the IAM permission is correctly linked to the new 
# identity without manual intervention or risk of typos.
resource "google_project_iam_member" "this" {
  project = var.project_id
  count   = length(var.roles)
  role    = "roles/${var.roles[count.index]}"
  member  = "serviceAccount:${google_service_account.this.email}"
}
