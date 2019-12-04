resource "google_service_account" "certbot-dns" {
  account_id   = "certbot-dns"
  display_name = "Certbot DNS Operator"
}

resource "google_project_iam_member" "project" {
  role   = "projects/code-supply/roles/${google_project_iam_custom_role.dns-automation.role_id}"
  member = "serviceAccount:${google_service_account.certbot-dns.email}"
}

resource "google_project_iam_custom_role" "dns-automation" {
  role_id = "dns_automation"
  title   = "DNS Automation"

  permissions = [
    "dns.changes.create",
    "dns.changes.get",
    "dns.managedZones.list",
    "dns.resourceRecordSets.create",
    "dns.resourceRecordSets.delete",
    "dns.resourceRecordSets.list",
    "dns.resourceRecordSets.update",
  ]
}
