# Component: Serverless Network Endpoint Group (NEG)
# Architecture: This is the "glue" that allows a Global Load Balancer to talk 
# to serverless backends like Cloud Run.
resource "google_compute_region_network_endpoint_group" "api" {
  name                  = "cloud-run"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    # URL Mask: Allows a single NEG to route to multiple services based on the path.
    url_mask = "/api/<service>"
  }
}

# Component: Backend Service (Compute)
# Architecture: Defines how the Load Balancer should communicate with the backend NEG.
resource "google_compute_backend_service" "api" {
  name                  = "cloud-run"
  load_balancing_scheme = "EXTERNAL"
  port_name             = "http"

  backend {
    group = google_compute_region_network_endpoint_group.api.self_link
  }
}

# Component: Global Forwarding Rule
# Architecture: The "Front Door" of your architecture. It provides a single global IP 
# address that receives all traffic on port 80.
resource "google_compute_global_forwarding_rule" "this" {
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  name                  = "cloud-run"
  port_range            = "80-80"
  target                = google_compute_target_http_proxy.this.self_link
}

# Component: Target HTTP Proxy
# Architecture: Routes incoming requests to the URL Map.
resource "google_compute_target_http_proxy" "this" {
  name    = "cloud-run"
  url_map = google_compute_url_map.this.self_link
}

# Component: Backend Bucket
# Architecture: Connects the Load Balancer to the GCS bucket for static content.
resource "google_compute_backend_bucket" "static_content" {
  name        = "static-content"
  description = "Contains all static content"
  bucket_name = google_storage_bucket.static.name
  enable_cdn  = false
}

# Component: URL Map
# Architecture: The "Traffic Cop." It directs traffic to different backends based 
# on the request's host or path.
resource "google_compute_url_map" "this" {
  name = "cloud-run"

  # Default Service: Traffic that doesn't match a path rule goes to GCS (static content).
  default_service = google_compute_backend_bucket.static_content.self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "path-matcher-1"
  }

  path_matcher {
    default_service = google_compute_backend_bucket.static_content.self_link
    name            = "path-matcher-1"

    # Path Rule: Traffic starting with /api/ is routed to the Cloud Run backend.
    # Architecture: This creates the "Hybrid" feel (Static + API) under one domain.
    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.api.self_link
    }
  }
}
