resource "google_monitoring_uptime_check_config" "affable" {
  display_name = "www.affable.app"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/"
    port         = "443"
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = element(split("/", data.google_project.project.id), 1)
      host       = "www.affable.app"
    }
  }
}

resource "google_monitoring_uptime_check_config" "code_supply" {
  display_name = "code.supply"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/"
    port         = "443"
    use_ssl      = true
    validate_ssl = false
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = element(split("/", data.google_project.project.id), 1)
      host       = "code.supply"
    }
  }
}

resource "google_monitoring_uptime_check_config" "andrewbruce" {
  display_name = "www.andrewbruce.net"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/"
    port         = "443"
    use_ssl      = true
    validate_ssl = false
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = element(split("/", data.google_project.project.id), 1)
      host       = "www.andrewbruce.net"
    }
  }
}
