# PROJECT ID INHERITANCE & DEPENDENCY CHAIN:
# 1. Inheritance: 'google_compute_network' inherits the 'project' value from the 
#    'provider "google"' block. 
# 2. Dependency Chain: This resource 'depends_on' the 'google_project_service' for 
#    Compute Engine. Both the service enablement resource AND the network resource 
#    inherit the same project ID from the provider.
# 3. Consistency: This ensures that Terraform first enables the necessary API in the 
#    correct project before attempting to create the network within that same project 
#    context, creating a unified and predictable deployment flow.

# LOCAL VARIABLES
# Using a local for the network name simplifies references and improves code maintainability.
locals {
  network_name = google_compute_network.this.name
}

# CUSTOM VPC NETWORK
# BEST PRACTICE: Setting 'auto_create_subnetworks' to 'false' (Custom Mode VPC).
# This provides granular control over the network topology, IP address ranges, 
# and regional placement, which is the standard for production environments. 
# Default VPCs (auto-mode) create subnets in every region, which increases 
# the security attack surface and risks IP address overlapping.
resource "google_compute_network" "this" {
  depends_on              = [google_project_service.this["compute"]]
  name                    = var.network
  auto_create_subnetworks = false
}

# CUSTOM SUBNETWORKS
# SECURITY: 'private_ip_google_access = "true"' is a critical security best practice.
# It allows VMs with only internal (private) IP addresses to communicate with 
# Google APIs and services (like Cloud SQL or Secret Manager) over the internal 
# Google network, rather than over the public internet. This keeps traffic secure 
# and allows us to deploy instances without exposing them to the internet via public IPs.
resource "google_compute_subnetwork" "this" {
  project  = var.project_id
  for_each = { for subnet in var.subnets : subnet.name => subnet }
  network  = local.network_name

  name                     = each.value.name
  region                   = each.value.region
  ip_cidr_range            = each.value.ip_cidr_range
  private_ip_google_access = "true"
}

