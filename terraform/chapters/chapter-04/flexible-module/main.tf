module "server1" {
  source = "./modules/server"
  name   = "${var.server_name}-1"
}

module "server2" {
  source       = "./modules/server"
  name         = "${var.server_name}-2"
  zone         = var.zone
  machine_size = "medium" # Valid values: small, medium, large
}

module "server3" {
  source       = "./modules/server"
  name         = "${var.server_name}-3"
  zone         = "us-central1-f"
  machine_size = "large" # Valid values: small, medium, large
  static_ip    = false
}
