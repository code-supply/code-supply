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
      "serviceAccount:${google_service_account.hosting.email}"
    ]
  }
  binding {
    role = "roles/storage.objectViewer"
    members = [
      "serviceAccount:${google_service_account.hosting.email}"
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
      "serviceAccount:${google_service_account.hosting-dev.email}"
    ]
  }
}

resource "google_storage_bucket" "hosting-uploads" {
  name     = "hosting-uploads"
  location = "EU"

  uniform_bucket_level_access = true

  cors {
    origin          = ["https://hosting.code.supply"]
    method          = ["POST"]
    response_header = ["*"]
    max_age_seconds = 1
  }
}

resource "google_storage_bucket_iam_policy" "hosting-uploads" {
  bucket      = google_storage_bucket.hosting-uploads.name
  policy_data = data.google_iam_policy.uploads.policy_data
}

resource "google_storage_bucket" "hosting-uploads-dev" {
  name     = "hosting-uploads-dev"
  location = "EU"

  uniform_bucket_level_access = true

  cors {
    origin          = ["http://hosting.code.test:4000"]
    method          = ["POST"]
    response_header = ["*"]
    max_age_seconds = 1
  }
}

resource "google_storage_bucket_iam_policy" "hosting-uploads-dev" {
  bucket      = google_storage_bucket.hosting-uploads-dev.name
  policy_data = data.google_iam_policy.uploads-dev.policy_data
}
