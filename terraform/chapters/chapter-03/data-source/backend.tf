terraform {
  backend "gcs" {
    bucket = "exp-terraform-states"
    prefix = "chap03/data-source"
  }
}
