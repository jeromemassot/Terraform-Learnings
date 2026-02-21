# PROJECT SERVICE ENABLEMENT
# This resource is foundational. It ensures that the necessary Google Cloud APIs 
# are enabled before Terraform tries to create resources that depend on them.

resource "google_project_service" "this" {
  # 1. Dynamic Enablement: We use 'for_each' to iterate through the list of 
  #    services defined in 'var.services'. This makes the configuration highly 
  #    reusable across different projects with different needs.
  for_each = toset(var.services)
  service  = "${each.key}.googleapis.com"

  # 2. Safety Best Practice: 'disable_on_destroy = false' is critical. 
  #    If this were 'true', running 'terraform destroy' would disable the API. 
  #    This can be catastrophic if the project has other resources (manually 
  #    created or from other TF modules) that rely on that same API. 
  #    Setting it to 'false' keeps the API active even if this module is removed.
  disable_on_destroy = false
}
