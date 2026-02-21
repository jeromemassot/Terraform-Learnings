# The output block is used to output the values of the resources
# The use of .this. allows to iterate on the collection of google_compute_instance resources.

# Despite each compute instance has only one network interface, we need to use the [0] index to access it.
# The same applies to the access_config.
output "public_ip_address" {
  value = var.static_ip ? google_compute_instance.this.network_interface.0.access_config.0.nat_ip : null
}

output "private_ip_address" {
  value = google_compute_instance.this.network_interface.0.network_ip
}

output "self_link" {
  value = google_compute_instance.this.self_link
}
