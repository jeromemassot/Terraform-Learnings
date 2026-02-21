# FINAL ARCHITECTURAL OUTPUT
# This is the 'Front Door' of your entire three-tier application.
# Since the VMs in the MIG only have internal/private IPs, this Global 
# Forwarding Rule IP is the single public address that users use to 
# access the Nginx web servers running in your Managed Instance Group.
output "website" {
  value = "http://${google_compute_global_forwarding_rule.this.ip_address}"
}
