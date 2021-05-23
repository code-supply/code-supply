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

    database_flags {
      name  = "max_connections"
      value = 200
    }
  }
}

output "sql_shared_public_ip" {
  value = google_sql_database_instance.shared_belgium.public_ip_address
}
