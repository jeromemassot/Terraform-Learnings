# Component: Terraform Remote State Data Source
# Architecture: This is the "Connective Tissue" between infrastructure layers.
# High-Level Goal: Chapter 07 uses a layered approach (Foundation -> Main). 
# This block allows the 'Main' application layer to read information about the 'Foundation' 
# layer without having to manage those resources itself.

data "terraform_remote_state" "foundation" {
  # Backend type must match the one used in the foundation module.
  backend = "gcs"
  config = {
    # The GCS bucket where the foundation's state file is stored.
    bucket = "exp-terraform-states"
    # The specific path (prefix) within the bucket for the foundation layer settings.
    prefix = "chap07/foundation"
  }
}

/*
WHY SHARING STATE IS CRITICAL FOR GCP ARCHITECTURE:

1. Metadata Synchronization:
   Resources exported from the foundation layer (like the VPC name, Subnet IDs, 
   Service Account emails, and Secret Manager IDs) are only known AFTER they are
   deployed. Remote state allows these dynamic values to be consumed as data 
   by the next layer.

2. Single Source of Truth:
   The Terraform 'state' file is the mapping between your code and real GCP 
   resources. By reading this state, the main layer receives the exact status 
   of the foundation (e.g., "The Redis IP is specifically 10.x.x.x").

3. Separation of Concerns (Decoupling):
   By sharing state instead of defining everything in one giant file, we limit 
   the "Blast Radius." You can update application code (Main) without risking 
   deleting the network or database (Foundation).

4. Scalability:
   Metadata sharing allows multiple teams to work on different layers. The 
   Network team manages the foundation state, while the App team reads it 
   to deploy Cloud Run services, ensuring both stay in sync automatically.

DEPLOIMENT ORDER & DEPENDENCIES:

How do we ensure 'Foundation' is deployed before 'Main'?

1. Implicit Code Dependency:
   Every time another resource in this 'Main' module uses a value from this 
   data source (e.g., `data.terraform_remote_state.foundation.outputs.vpc_id`), 
   Terraform builds a dependency. If the foundation state file (in GCS) 
   does not exist yet, 'terraform plan' in this directory will FAIL. This 
   prevents you from accidentally deploying the app before the network exists.

2. Operational Sequence:
   In this repository structure, modules are separated into directories. 
   Terraform treats each as a separate "Root Module." Therefore, the 
   deployment order is enforced by the order of your CLI commands:
   Step A: 'cd foundation' -> 'terraform apply'
   Step B: 'cd main' -> 'terraform apply'

3. Why not one single module?
   By separating them, 'Foundation' becomes your stable base. You can 
   deploy 'Main' dozens of times a day without the risk of Terraform 
   re-calculating or accidentally modifying your core network or DB settings.
*/
