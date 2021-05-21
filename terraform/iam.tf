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

resource "google_project_iam_member" "affable-cloud-sql" {
  project = data.google_project.project.id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.affable.email}"
}

resource "google_service_account" "affable-dev" {
  account_id   = "affable-dev"
  display_name = "Affable application in development"
}

resource "google_service_account_iam_binding" "affable-workload-identity" {
  service_account_id = google_service_account.affable.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[affable/affable]",
  ]
}

resource "google_service_account" "imgproxy" {
  account_id   = "imgproxy"
  display_name = "imgproxy application"
}

resource "google_service_account_iam_binding" "imgproxy-workload-identity" {
  service_account_id = google_service_account.imgproxy.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[affable/imgproxy]",
  ]
}
