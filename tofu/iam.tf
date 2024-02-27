resource "google_service_account" "concourse" {
  account_id   = "concourse"
  display_name = "Concourse"
}

resource "google_service_account" "dns-cert-manager" {
  account_id   = "dns-cert-manager"
  display_name = "DNS modifier for Cert Manager"
}

resource "google_project_iam_binding" "dns-cert-manager" {
  project = data.google_project.project.id
  role    = "roles/dns.admin"

  members = [
    "serviceAccount:${google_service_account.dns-cert-manager.email}",
  ]
}

resource "google_service_account" "hosting" {
  account_id   = "hosting"
  display_name = "Hosting application"
}

resource "google_project_iam_member" "hosting-signblob" {
  project = data.google_project.project.id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.hosting.email}"
}

resource "google_project_iam_member" "hosting-cloud-sql" {
  project = data.google_project.project.id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.hosting.email}"
}

resource "google_service_account" "hosting-dev" {
  account_id   = "hosting-dev"
  display_name = "Hosting application in development"
}

resource "google_project_iam_member" "hosting-dev-signblob" {
  project = data.google_project.project.id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.hosting-dev.email}"
}

resource "google_service_account" "imgproxy" {
  account_id   = "imgproxy"
  display_name = "imgproxy application"
}
