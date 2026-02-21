# DATA SOURCES vs RESOURCES
# In Terraform, 'data' components are Read-Only objects. Unlike 'resource' blocks which 
# create/manage infrastructure, 'data' blocks fetch information from existing providers 
# (in this case, Google Cloud) to be used elsewhere in our configuration.

# IAP FORWARDERS IP RANGES
# This data source retrieves the current IP ranges used by Google's Identity-Aware Proxy (IAP).
# Nature: These are public IP ranges maintained by Google (specifically 35.235.240.0/20).
# Meaning in this Architecture: 
# Using a Managed Instance Group (MIG) often involves private instances with no public IPs.
# To allow SSH access safely, we use IAP as a "TCP forwarding" tunnel. 
# These IP ranges must be whitelisted in our firewall (ingress) so that when an 
# authenticated user connects via 'gcloud compute ssh --tunnel-through-iap', 
# Google's IAP proxies can hand off the traffic to our internal instances.
data "google_netblock_ip_ranges" "iap_forwarders" {
  range_type = "iap-forwarders"
}

# LOAD BALANCER / MIG HEALTH CHECKER IP RANGES
# Nature: These are the IP ranges used by Google's centralized health-checking systems.
# Meaning in this Architecture:
# For a Managed Instance Group to operate correctly under a Load Balancer, Google must 
# verify that instances are 'healthy' before sending traffic. Because health checks 
# come from a specific set of Google-internal IP ranges, we fetch them here to 
# dynamically create firewall rules that allow this traffic without hardcoding IP addresses.
data "google_netblock_ip_ranges" "health_checkers" {
  range_type = "health-checkers"
}

