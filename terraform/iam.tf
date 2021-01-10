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

resource "google_service_account" "affable" {
  account_id   = "affable"
  display_name = "Affable application"
}

resource "google_service_account_iam_binding" "affable-workload-identity" {
  service_account_id = google_service_account.affable.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[affable/affable]",
  ]
}

resource "google_project_iam_binding" "affable-token-creator" {
  project = data.google_project.project.id
  role    = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:${google_service_account.affable.email}",
    "user:bruciemoose@gmail.com",
  ]
}
