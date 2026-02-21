# --- GENERATION OF ROOT PASSWORD ---

# 1. RANDOM PASSWORD GENERATOR
# This resource creates a secure, random string locally in Terraform's state.
resource "random_password" "root" {
  length  = 12    # Number of characters in the password.
  special = false # Excludes special characters to avoid potential shell escaping issues.
}

# 2. SECRET MANAGER "CONTAINER"
# This resource creates the logical 'secret' object in GCP Secret Manager (the metadata/label).
resource "google_secret_manager_secret" "root_pw" {
  secret_id = "db-root-pw" # The unique identifier for this secret in the GCP project.

  # 'replication' defines how the secret is stored.
  replication {
    automatic = true # Google automatically replicates the secret across multiple regions for high availability.
  }
}

# 3. SECRET "VERSION" (THE ACTUAL DATA)
# This resource adds the sensitive value (the password) to the secret container created above.
resource "google_secret_manager_secret_version" "root_pw" {
  # References the ID of the secret container.
  secret = google_secret_manager_secret.root_pw.id
  # The actual sensitive payload. Here we use the result from the 'random_password' resource.
  secret_data = random_password.root.result
}

# --- GENERATION OF APPLICATION USER PASSWORD ---
# (The pattern below repeats the same three-step logic for the non-root user)

resource "random_password" "user" {
  length  = 8
  special = false
}

resource "google_secret_manager_secret" "user_pw" {
  secret_id = "db-user-pw"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "user_pw" {
  secret      = google_secret_manager_secret.user_pw.id
  secret_data = random_password.user.result
}

