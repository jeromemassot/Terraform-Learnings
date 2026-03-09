terraform {
  backend "gcs" {
    bucket = "exp-terraform-states"
    prefix = "chap08"
  }
}
