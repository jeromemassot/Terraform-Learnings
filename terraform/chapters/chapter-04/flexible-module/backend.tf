terraform {
  backend "gcs" {
    bucket = "exp-terraform-states"
    prefix = "chap04/flexible-module"
  }
}
