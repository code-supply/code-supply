data "google_iam_policy" "uploads" {
  binding {
    role = "roles/storage.admin"
    members = [
      "user:bruciemoose@gmail.com"
    ]
  }
  binding {
    role = "roles/storage.objectViewer"
    members = [
      "serviceAccount:${google_service_account.imgproxy.email}"
    ]
  }
  binding {
    role = "roles/storage.objectCreator"
    members = [
      "serviceAccount:${google_service_account.affable.email}"
    ]
  }
}

data "google_iam_policy" "uploads-dev" {
  binding {
    role = "roles/storage.admin"
    members = [
      "user:bruciemoose@gmail.com"
    ]
  }
  binding {
    role = "roles/storage.objectViewer"
    members = [
      "serviceAccount:${google_service_account.imgproxy.email}"
    ]
  }
  binding {
    role = "roles/storage.objectCreator"
    members = [
      "serviceAccount:${google_service_account.affable-dev.email}"
    ]
  }
}

resource "google_storage_bucket" "affable-uploads" {
  name     = "affable-uploads"
  location = "EU"

  uniform_bucket_level_access = true

  cors {
    origin          = ["http://localhost:4000"]
    method          = ["POST"]
    response_header = ["*"]
    max_age_seconds = 1
  }
}

resource "google_storage_bucket_iam_policy" "affable-uploads" {
  bucket      = google_storage_bucket.affable-uploads.name
  policy_data = data.google_iam_policy.uploads.policy_data
}

resource "google_storage_bucket" "affable-uploads-dev" {
  name     = "affable-uploads-dev"
  location = "EU"

  uniform_bucket_level_access = true

  cors {
    origin          = ["http://localhost:4000"]
    method          = ["POST"]
    response_header = ["*"]
    max_age_seconds = 1
  }
}

resource "google_storage_bucket_iam_policy" "affable-uploads-dev" {
  bucket      = google_storage_bucket.affable-uploads-dev.name
  policy_data = data.google_iam_policy.uploads-dev.policy_data
}
