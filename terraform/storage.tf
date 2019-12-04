resource "google_storage_bucket" "backups" {
  name     = "code-supply-backups"
  location = "EU"
}

resource "google_storage_bucket_acl" "backups-acl" {
  bucket         = google_storage_bucket.backups.name
  predefined_acl = "private"
}

