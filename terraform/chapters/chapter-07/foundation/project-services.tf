# Resource: Google Cloud Project Service
# Components: Enabling or disabling services for a project.
# Syntax: The `resource` block defines a physical component in your infrastructure.
resource "google_project_service" "this" {
  for_each           = toset(var.services)
  service            = "${each.key}.googleapis.com"
  disable_on_destroy = false
}
