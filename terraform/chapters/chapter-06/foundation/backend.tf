terraform {
  backend "gcs" {
    bucket = "exp-terraform-states"
    prefix = "chap06/foundation"
  }
}
