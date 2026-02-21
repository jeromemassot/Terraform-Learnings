# Resource: Google Cloud Service Account
# Components: A Service Account (SA) is a special type of Google account intended to represent a non-human user.
# Syntax: The `resource` block defines a physical component in your infrastructure.
resource "google_service_account" "this" {
  # Terraform Functionality: `depends_on` is a meta-argument used to define explicit dependencies.
  # Here, it ensures the IAM API is fully enabled before Terraform attempts to create the SA.
  depends_on = [google_project_service.this["iam"]]

  # The unique ID used to name the service account (e.g., "cloudrun").
  account_id = var.sa_name

  # A user-friendly name displayed in the Google Cloud Console.
  # Syntax: `${}` is string interpolation, allowing variables to be embedded in strings.
  display_name = "${var.sa_name} Service Account"
}

# Resource: Project IAM Member
# Services: Assigning specific roles to the service account at the project level.
resource "google_project_iam_member" "this" {
  # The ID of the project where permissions are granted.
  project = var.project_id

  # Terraform Functionality: `for_each` is a meta-argument that creates a resource instance for each element in a map or set.
  # Syntax: `toset()` converts the list of roles into a set to ensure each role is unique and compatible with for_each.
  for_each = toset(var.roles)

  # The role being assigned.
  # Syntax: `each.key` references the current value from the `for_each` set.
  role = "roles/${each.key}"

  # The identity receiving the permissions.
  # Syntax: References the email attribute of the previously defined service account resource.
  member = "serviceAccount:${google_service_account.this.email}"
}
