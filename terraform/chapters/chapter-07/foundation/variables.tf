# Terraform Syntax: `variable` blocks define input parameters for the module.
# Input variables allow you to customize infrastructure without hardcoding values.

# Component: The logical container for all your Google Cloud resources.
variable "project_id" {
  # Syntax: `type` ensures the input value matches the expected format (in this case, a string).
  type        = string
  description = "ID of the Google Project"
}

# Component: A VPC (Virtual Private Cloud) network name.
variable "network" {
  type = string
}

# Component: Google Cloud Regions are specific geographical locations to host resources.
# Using regions close to your users reduces latency.
variable "region" {
  type        = string
  description = "Default Region"
  # Syntax: `default` provides a fallback value if none is provided in .tfvars.
  default = "us-central1"
}

# Component: Google Cloud Zones are isolated locations within a region.
variable "zone" {
  type        = string
  description = "Default Zone"
  default     = "us-central1-a"
}

# Component: Subnetworks (Subnets) allow you to segment your VPC into specific CIDR ranges.
# This variable uses a complex object type to represent a list of subnet configurations.
variable "subnets" {
  # Syntax: `list(object({...}))` defines a structural type containing multiple attributes.
  type = list(object({
    name          = string
    region        = string
    ip_cidr_range = string
  }))
}

# Service: APIs that must be enabled to interact with specific Google Cloud features.
variable "services" {
  type = list(string)
}

# Service: IAM Roles that define "what" can be done (e.g., secretmanager.secretAccessor).
variable "roles" {
  type = list(string)
}

# Component: The name for the Service Account, which act as the identity for your application.
variable "sa_name" {
  type = string
}

# Component: Serverless VPC Access Connector.
# This is a critical bridge that allows serverless apps (Cloud Run) to talk to VPC resources.
variable "vpc_connector_name" {
  # Syntax: Variables without defaults are "required" inputs.
  type = string
}
