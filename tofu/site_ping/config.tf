variable "host" {}
variable "path" {}
variable "google_project_id" {}
variable "display_name" {}
variable "notification_channels" {
  type = list(string)
}

resource "google_monitoring_uptime_check_config" "site" {
  display_name = var.display_name
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = var.path
    port         = "443"
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = element(split("/", var.google_project_id), 1)
      host       = var.host
    }
  }
}
