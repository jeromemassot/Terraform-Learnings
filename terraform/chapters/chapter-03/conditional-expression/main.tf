resource "google_compute_address" "static" {
  count = var.static_ip ? 1 : 0
  name  = "ipv4-address-${count.index}"
}

resource "google_compute_instance" "this" {
  name         = var.server_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    dynamic "access_config" {
      for_each = google_compute_address.static
      content {
        nat_ip = access_config.value.address
      }
    }
  }
}

