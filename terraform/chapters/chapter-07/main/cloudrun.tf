# Component: Google Cloud Run (Serverless Compute)
# Architecture: 'hello' is a stateless service exposed to the Global Load Balancer.
resource "google_cloud_run_service" "hello" {
  name     = "hello"
  location = var.region

  metadata {
    annotations = {
      # Ingress Hardening: Restricts traffic so it can only come from the Load Balancer 
      # or internal VPC sources. This prevents users from bypassing your domain/WAF.
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }

  template {
    spec {
      containers {
        image = var.container_images.hello
      }
      # Identity: Uses the Service Account created in the foundation layer, 
      # pulled from the remote state.
      service_account_name = data.terraform_remote_state.foundation.outputs.service_account_email
    }
  }
}

# Component: IAM Policy for Cloud Run
# Architecture: Granting 'roles/run.invoker' to 'allUsers' allows the public internet 
# (via the Load Balancer) to reach this service.
resource "google_cloud_run_service_iam_binding" "hello" {
  location = google_cloud_run_service.hello.location
  service  = google_cloud_run_service.hello.name
  role     = "roles/run.invoker"
  members = [
    "allUsers",
  ]
}

# Component: Cloud Run Service with Private Connectivity
# Architecture: The 'redis' service needs to talk to the private Memorystore instance.
resource "google_cloud_run_service" "redis" {
  name     = "redis"
  location = var.region

  metadata {
    annotations = {
      # Same ingress restriction as the hello service.
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }

  template {
    metadata {
      annotations = {
        # Bridge Pattern: Connects this serverless service to the VPC via the 
        # Serverless VPC Access Connector.
        "run.googleapis.com/vpc-access-connector" = var.vpc_connector_name

        # Egress Control: Routes only internal traffic (to Redis) through the connector.
        # This keeps the container efficient for public internet requests.
        "run.googleapis.com/vpc-access-egress" = "private-ranges-only"
      }
    }
    spec {
      containers {
        image = var.container_images.redis

        # Component: Secret Injection
        # Service: Pulled from Secret Manager (defined in foundation layer).
        env {
          name = "REDIS_IP"
          value_from {
            secret_key_ref {
              # Syntax: Dynamically references the secret ID found in the remote state.
              name = data.terraform_remote_state.foundation.outputs.redis_ip_secret_id
              key  = "latest"
            }
          }
        }
      }
      service_account_name = data.terraform_remote_state.foundation.outputs.service_account_email
    }
  }
}

resource "google_cloud_run_service_iam_binding" "redis" {
  location = google_cloud_run_service.redis.location
  service  = google_cloud_run_service.redis.name
  role     = "roles/run.invoker"
  members = [
    "allUsers",
  ]
}
