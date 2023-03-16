resource "google_storage_bucket" "backups" {
  name     = "code-supply-backups"
  location = "EU"
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_access_control" "backups-concourse" {
  bucket = google_storage_bucket.backups.name
  role   = "WRITER"
  entity = "user-${google_service_account.concourse.email}"
}
