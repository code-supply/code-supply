variable "andrew_ip" {
  default = "81.187.237.24"
}

resource "google_sql_database_instance" "shared" {
  name             = "shared"
  database_version = "POSTGRES_12"
  region           = "europe-west2"

  settings {
    tier              = "db-f1-micro"
    disk_size         = 10
    availability_type = "ZONAL"

    location_preference {
      zone = "europe-west2-c"
    }

    backup_configuration {
      enabled = true
    }

    ip_configuration {
      require_ssl = true

      authorized_networks {
        name  = "andrew"
        value = var.andrew_ip
      }
    }
  }
}

resource "google_sql_database" "affable" {
  name     = "affable"
  instance = google_sql_database_instance.shared.name
}

resource "google_sql_user" "affable" {
  name     = "affable"
  instance = google_sql_database_instance.shared.name
  password = "changeme"
}

resource "google_sql_user" "andrew" {
  name     = "andrew"
  instance = google_sql_database_instance.shared.name
  password = "changeme"
}

resource "google_service_account" "sql_shared_affable" {
  account_id   = "sql-shared-affable"
  display_name = "sql-shared-affable"
}

resource "google_project_iam_member" "sql_shared_affable" {
  project = "code-supply"
  role    = "roles/cloudsql.client"

  member = "serviceAccount:${google_service_account.sql_shared_affable.email}"
}

output "sql_shared_public_ip" {
  value = google_sql_database_instance.shared.public_ip_address
}
