# FIREWALL RULES FOR IDENTITY-AWARE PROXY (IAP) SSH ACCESS

# This rule allows authenticated users to SSH into instances that have no public IP.
resource "google_compute_firewall" "allow_iap" {
  # 'name': Uniquely identifies the rule within the project.
  name = "${local.network_name}-allow-iap"
  # 'network': The VPC where this rule is applied.
  network = local.network_name

  # 'allow': Specifies the traffic type permitted.
  allow {
    # 'protocol': 'tcp' is required for SSH.
    protocol = "tcp"
    # 'ports': Port 22 is the standard SSH port.
    ports = ["22"]
  }

  # 'source_ranges': CRITICAL SECURITY. We only allow traffic coming from Google's 
  # official IAP proxy IP ranges (fetched in data.tf). This ensures that only 
  # traffic channeled through IAP's authentication layer can reach the instances.
  source_ranges = data.google_netblock_ip_ranges.iap_forwarders.cidr_blocks_ipv4

  # 'target_tags': This rule is NOT applied to every VM. It only applies to 
  # instances tagged with "allow-iap". This follows the Principle of Least Privilege.
  target_tags = ["allow-iap"]
}

# FIREWALL RULES FOR LOAD BALANCER HEALTH CHECKS

# This rule allows Google's health checkers to verify the status of our MIG.
resource "google_compute_firewall" "allow_health_check" {
  name    = "${local.network_name}-allow-health-check"
  network = local.network_name

  allow {
    protocol = "tcp"
    # Port 80 is used because the Managed Instance Group is hosting a web server (Nginx).
    ports = ["80"]
  }

  # 'source_ranges': Only permits traffic from Google's centralized health check systems.
  source_ranges = data.google_netblock_ip_ranges.health_checkers.cidr_blocks_ipv4

  # 'target_tags': Only applies to instances tagged with "allow-health-check".
  # This ensures we don't accidentally open port 80 on database or other internal servers.
  target_tags = ["allow-health-check"]
}
