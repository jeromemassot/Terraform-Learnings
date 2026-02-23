# Terraform Functionality: Locals are used here to dynamically look up the subnet name 
# from the subnetwork resource created in vpc.tf.
locals {
  subnet_name = google_compute_subnetwork.this[var.subnets[0].name].name
}

# Component: Serverless VPC Access Connector
# Service: This acts as the "bridge" between serverless environments (like Cloud Run) and your VPC.
# Importance: By default, Cloud Run cannot "see" private resources like Redis. The connector
# provides a private path for Cloud Run to reach internal IPs within the VPC.
resource "google_vpc_access_connector" "this" {
  depends_on = [google_compute_subnetwork.this]
  name       = var.vpc_connector_name
  region     = var.region
  subnet {
    name = local.subnet_name
  }
}

# Component: Google Cloud Memorystore for Redis
# Service: A fully managed in-memory data store service for Redis.
# Connectivity: `authorized_network` ensures the Redis instance is only accessible from within the specified VPC.
resource "google_redis_instance" "this" {
  name               = "redis"
  memory_size_gb     = 1
  tier               = "BASIC"
  region             = var.region
  authorized_network = google_compute_network.this.self_link
}

# Component: Secret Manager (Secret Metadata)
# Service: A secure and convenient storage system for sensitive information.
# Why store the Redis IP as a Secret?
# 1. Security: It prevents sensitive internal infrastructure details from being hardcoded in application code or visible in plaintext in the Google Cloud Console's Cloud Run environment variable UI.
# 2. Dynamic Discovery: The application (Cloud Run) doesn't need to know the IP beforehand. It simply requests the "latest" version of this secret at runtime.
# 3. Automation: If the Redis instance is ever recreated and gets a new IP, Terraform updates this secret, and the application automatically picks up the new IP without a redeployment or code change.
resource "google_secret_manager_secret" "redis_ip" {
  depends_on = [google_project_service.this["secretmanager"]]
  secret_id  = "redis-ip"
  replication {
    auto {}
  }
}

# Component: Secret Manager (Secret Version)
# Syntax: This resource creates the actual "value" (the Redis IP host) inside the secret container defined above.
resource "google_secret_manager_secret_version" "redis_ip" {
  secret      = google_secret_manager_secret.redis_ip.id
  secret_data = google_redis_instance.this.host
}
