output "URLs" {
  description = "URLs of the server"
  value       = [for ip in google_compute_instance.this.network_interface[0].access_config[*].nat_ip : format("http://%s", ip)]
}
