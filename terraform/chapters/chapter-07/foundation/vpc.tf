# Terraform Functionalitiy: `locals` blocks define local values that can be reused throughout the module.
# Syntax: Accessing a local value is done via `local.<name>`.
locals {
  network_name = google_compute_network.this.name
}

# Resource: Google Cloud VPC Network
# Components: A VPC (Virtual Private Cloud) is a global private network within Google Cloud.
# Syntax: The `google_compute_network` resource defines the network layer.
resource "google_compute_network" "this" {
  # Terraform Functionality: `depends_on` creates an explicit dependency.
  # Here, it ensures the Compute Engine API is enabled before the network is created.
  depends_on = [google_project_service.this["compute"]]

  # The name of the VPC network, sourced from variables.
  name = var.network

  # Google Cloud Best Practice: Setting `auto_create_subnetworks = false` creates a Custom Mode VPC.
  # This provides full control over subnet IP ranges and regions.
  auto_create_subnetworks = false
}

# Resource: Google Cloud Subnetwork
# Components: Subnets partition VPC IP address space into smaller segments within a specific region.
resource "google_compute_subnetwork" "this" {
  project = var.project_id

  # Terraform Syntax: `for_each` is used to create multiple subnetwork instances.
  # The expression `{ for subnet in var.subnets : subnet.name => subnet }` transforms a list of objects 
  # into a map keyed by the subnet name, which is required for `for_each`.
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  # The VPC network this subnet belongs to.
  network = local.network_name

  # Syntax: `each.value` references the object from the current iteration of the map.
  name          = each.value.name
  region        = each.value.region
  ip_cidr_range = each.value.ip_cidr_range

  # Google Cloud Component: Private Google Access.
  # This allows resources in this subnet (without public IPs) to reach Google API endpoints.
  # This is crucial for serverless integration and secure backend communication.
  private_ip_google_access = "true"
}
