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
  }
}

resource "google_sql_ssl_cert" "shared_andrew" {
  common_name = "andrew"
  instance    = google_sql_database_instance.shared.name
}

output "sql_shared_andrew_key" {
  value = google_sql_ssl_cert.shared_andrew.private_key
}

output "sql_shared_andrew_cert" {
  value = google_sql_ssl_cert.shared_andrew.cert
}

output "sql_shared_andrew_ca_cert" {
  value = google_sql_ssl_cert.shared_andrew.server_ca_cert
}
