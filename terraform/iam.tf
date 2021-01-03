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

resource "google_project_iam_binding" "affable-workload-identity" {
  project = data.google_project.project.id
  role    = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${google_service_account.affable.email}",
  ]
}
