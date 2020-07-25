resource "google_sql_database_instance" "shared_belgium" {
  name             = "shared-belgium"
  database_version = "POSTGRES_12"
  region           = "europe-west1"

  settings {
    tier              = "db-f1-micro"
    disk_size         = 10
    availability_type = "ZONAL"

    location_preference {
      zone = "europe-west1-b"
    }

    backup_configuration {
      enabled  = true
      location = "eu"
    }

    maintenance_window {
      day  = 2
      hour = 1
    }
  }
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
  value = google_sql_database_instance.shared_belgium.public_ip_address
}
