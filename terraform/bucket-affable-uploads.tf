resource "google_storage_bucket" "affable-uploads" {
  name     = "affable-uploads"
  location = "EU"

  cors {
    origin          = ["http://localhost:4000"]
    method          = ["POST"]
    response_header = ["*"]
    max_age_seconds = 1
  }
}

resource "google_storage_bucket_acl" "affable-uploads" {
  bucket = google_storage_bucket.affable-uploads.name

  role_entity = [
    "WRITER:user-${google_service_account.affable.email}"
  ]
}

resource "google_storage_bucket" "affable-uploads-dev" {
  name     = "affable-uploads-dev"
  location = "EU"

  cors {
    origin          = ["http://localhost:4000"]
    method          = ["POST"]
    response_header = ["*"]
    max_age_seconds = 1
  }
}

resource "google_storage_bucket_acl" "affable-uploads-dev" {
  bucket = google_storage_bucket.affable-uploads-dev.name

  role_entity = [
    "WRITER:user-${google_service_account.affable-dev.email}"
  ]
}
