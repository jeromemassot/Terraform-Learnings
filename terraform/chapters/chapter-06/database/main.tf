# 1. INSTANCE NAME RANDOMIZATION

# Cloud SQL instance names cannot be reused immediately after deletion. 
# We add a random suffix to ensure unique names during rapid development cycles.
resource "random_string" "this" {
  length  = 4
  upper   = false
  special = false
}

# 2. CLOUD SQL INSTANCE

# This is the heavy resource providing the MySQL engine.
resource "google_sql_database_instance" "this" {
  # Dynamic name using the random suffix.
  name             = "${var.db_settings.instance_name}-${random_string.this.result}"
  database_version = var.db_settings.database_version
  region           = var.region

  # Security: Passwords are NOT hardcoded; they are referenced from local random_password resources.
  root_password = random_password.root.result

  settings {
    tier = var.db_settings.database_tier # e.g. db-f1-micro
  }

  # Safety: set to false for learning; in production, this should be true.
  deletion_protection = false
}

# 3. LOGICAL DATABASE

# Creates the specific schema/database inside the instance.
resource "google_sql_database" "this" {
  name     = var.db_settings.db_name
  instance = google_sql_database_instance.this.name
}

# 4. DATABASE USER

# Creates the application-level user account.
resource "google_sql_user" "sql" {
  name     = var.db_settings.user_name
  instance = google_sql_database_instance.this.name
  password = random_password.user.result
}

# 5. CONNECTION NAME SECRET

# We store the 'Connection Name' (project:region:instance) as a secret.
# This allows the Application Tier (MIG) to fetch it at runtime for the Cloud SQL Auth Proxy.
resource "google_secret_manager_secret" "connection_name" {
  secret_id = "connection-name"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "connection_name" {
  secret = google_secret_manager_secret.connection_name.id

  # KEY INSIGHT: 'connection_name' is a Computed Attribute. 
  # It is 'discovered' from the GCP API only after the database instance is 
  # successfully deployed. Terraform waits for this value to be available 
  # before creating this secret version.
  secret_data = google_sql_database_instance.this.connection_name
}

