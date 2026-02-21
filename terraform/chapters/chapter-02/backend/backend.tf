terraform {
  backend "gcs" {
    bucket = "exp-terraform-states"
    prefix = "chap02/backend"
  }
}
