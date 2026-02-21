# 1. EXTERNAL LOAD BALANCER - FRONTEND
# The "Front Door" of the architecture.
resource "google_compute_global_forwarding_rule" "this" {
  name                  = var.load_balancer.forward_rule_name
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  # Sends traffic to the Target HTTP Proxy.
  target = google_compute_target_http_proxy.this.self_link
}

# 2. HEALTH CHECK
# Monitors individual instances to ensure they are serving traffic.
resource "google_compute_health_check" "this" {
  name = "http-health-check"
  http_health_check {
    # Probes port 80. If an instance fails this check, it's removed from the LB rotation.
    port = 80
  }
}

# 3. BACKEND SERVICE
# The logic core of the LB: links health checks to the instance group.
resource "google_compute_backend_service" "this" {
  name                  = var.load_balancer.backend_service_name
  health_checks         = [google_compute_health_check.this.self_link]
  load_balancing_scheme = "EXTERNAL"

  backend {
    # Directs traffic to the Managed Instance Group.
    balancing_mode = "UTILIZATION"
    group          = google_compute_region_instance_group_manager.this.instance_group
  }
}

# 4. URL MAP
# The Routing Table: decides where to send traffic based on the URI.
resource "google_compute_url_map" "this" {
  name = var.load_balancer.url_map_name
  # Sends all incoming traffic to our one backend service.
  default_service = google_compute_backend_service.this.self_link
}

# 5. TARGET HTTP PROXY
# Acts as the bridge between the Frontend and the URL Map.
resource "google_compute_target_http_proxy" "this" {
  name    = var.load_balancer.target_proxy_name
  url_map = google_compute_url_map.this.self_link
}

