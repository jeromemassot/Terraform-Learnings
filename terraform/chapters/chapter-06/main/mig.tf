# 1. COMPUTE INSTANCE TEMPLATE
# The "Blueprint" for every VM in our fleet. It defines what to build, but doesn't build it yet.
# The usage of a name_prefix is to avoid name collisions when creating multiple instance templates,
# and also due to the fact that the new instance template will be created before the previous one is destroyed.
resource "google_compute_instance_template" "this" {
  name_prefix  = var.mig.instance_template_name_prefix
  region       = var.region
  machine_type = var.mig.machine_type

  # Defines the boot disk and the OS image.
  disk {
    source_image = var.mig.source_image
  }

  # NETWORKING: Note how we reference the remote 'foundation' state.
  network_interface {
    # Dynamically retrieves the subnet self-link from the foundation layer.
    subnetwork = data.terraform_remote_state.foundation.outputs.subnetwork_self_links["iowa"]
    access_config {
      # This empty block gives the instance an ephemeral public IP.
      # While the VMs are private-first, this allows basic outbound internet connectivity.
    }
  }

  # RUNTIME CONFIG: Script that runs the first time the machine boots up.
  metadata_startup_script = file("startup.sh")

  # NETWORK TAGS: Crucial for applying the firewall rules we defined in foundation.
  tags = [
    "allow-iap",         # Permitting SSH via Identity-Aware Proxy.
    "allow-health-check" # Permitting Load Balancer probe traffic.
  ]

  # IDENTITY: The Service Account that gives the VM its permissions.
  service_account {
    # Retrieves the email from foundation layer output.
    email  = data.terraform_remote_state.foundation.outputs.service_account_email
    scopes = ["cloud-platform"] # Best practice: give access to cloud-platform and restrict via IAM roles.
  }

  lifecycle {
    # Best practice for templates: create the new one before destroying the old one
    # to avoid downtime during rolling updates.
    create_before_destroy = true
  }
}

# 2. MANAGED INSTANCE GROUP (MIG)
# The "Controller" that monitors and manages the actual VM instances.
resource "google_compute_region_instance_group_manager" "this" {
  name               = var.mig.mig_name
  region             = var.region
  base_instance_name = var.mig.mig_base_instance_name
  target_size        = var.mig.target_size # Number of replicas to maintain.

  version {
    instance_template = google_compute_instance_template.this.id
  }

  # Named ports allow the Load Balancer to refer to "http" instead of hardcoding 80.
  named_port {
    name = "http"
    port = 80
  }

  # POLICY: Defines how instances are updated when the template changes.
  update_policy {
    type            = "PROACTIVE" # Automatically replaces instances when a change occurs.
    minimal_action  = "REPLACE"
    max_surge_fixed = 3 # Can temporarily run 3 extra instances during a rollout.
  }
}


