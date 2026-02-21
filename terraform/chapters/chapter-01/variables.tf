variable "project_id" {
  type        = string
  description = "The Google Cloud Project ID"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "server_name" {
  type    = string
  default = "terraform-verify"
}
