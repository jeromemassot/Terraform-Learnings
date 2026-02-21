terraform {
  backend "gcs" {
    bucket = "exp-terraform-states"
    prefix = "chap05/directory-structure/dev"
  }
}
