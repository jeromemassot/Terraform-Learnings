# Component: Google Cloud Storage (GCS)
# Service: A scalable, durable, and highly available object storage service.
# Architecture: In this chapter, GCS acts as the "Static Backend" for the Global Load Balancer.
resource "google_storage_bucket" "static" {
  # Naming: Buckets have a global namespace; using the project ID ensures uniqueness.
  name     = "${var.project_id}-static"
  location = var.region

  # Security Best Practice: Uniform bucket-level access ensures that permissions are managed 
  # consistently at the bucket level rather than per-object.
  uniform_bucket_level_access = true

  # Feature: Static Website Hosting
  # This enables the bucket to act as a web server, serving defaults like index.html.
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# Component: IAM Binding (Public Access)
# Architecture: For a public-facing website, we grant `Storage Object Viewer` to `allUsers`.
# This allows the Global Load Balancer to fetch assets and serve them to the public internet.
resource "google_storage_bucket_iam_binding" "binding" {
  bucket  = google_storage_bucket.static.name
  role    = "roles/storage.objectViewer"
  members = ["allUsers", ]
}

# Component: GCS Objects (The Assets)
# Architecture: These represent the files uploaded to the bucket.
# `cache_control = "no-store"` ensures that the browser always fetches the latest version 
# during this learning exercise.
resource "google_storage_bucket_object" "index" {
  name          = "index.html"
  source        = "../static/index.html"
  bucket        = google_storage_bucket.static.name
  cache_control = "no-store"
}

resource "google_storage_bucket_object" "four_0_four" {
  name          = "404.html"
  source        = "../static/404.html"
  bucket        = google_storage_bucket.static.name
  cache_control = "no-store"
}

resource "google_storage_bucket_object" "image" {
  name          = "img/TerraformForGCP.jpg"
  source        = "../static/img/TerraformForGCP.jpg"
  bucket        = google_storage_bucket.static.name
  cache_control = "no-store"
}

