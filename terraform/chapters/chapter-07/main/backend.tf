terraform {
  backend "gcs" {
    bucket = "exp-terraform-states"
    prefix = "chap07/main"
  }
}
