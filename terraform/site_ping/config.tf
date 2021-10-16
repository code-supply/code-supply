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

resource "google_monitoring_alert_policy" "site" {
  display_name = var.display_name

  notification_channels = var.notification_channels

  combiner = "OR"

  conditions {
    display_name = "Uptime Health Check for ${var.display_name}"

    condition_threshold {
      comparison      = "COMPARISON_GT"
      duration        = "60s"
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" resource.type=\"uptime_url\" metric.label.\"check_id\"=\"${google_monitoring_uptime_check_config.site.uptime_check_id}\""
      threshold_value = 1

      aggregations {
        alignment_period     = "1200s"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields      = ["resource.*"]
        per_series_aligner   = "ALIGN_NEXT_OLDER"
      }

      trigger {
        count   = 0
        percent = 100
      }
    }
  }
}
