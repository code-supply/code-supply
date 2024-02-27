variable "sites" {
  type = map(any)
  default = {
    code-supply = {
      display_name = "Code Supply"
      host         = "code.supply"
      path         = "/"
    },
    andrewbruce = {
      display_name = "Andrew Bruce"
      host         = "www.andrewbruce.net"
      path         = "/"
    }
  }
}

module "monitoring" {
  source            = "./site_ping"
  for_each          = var.sites
  google_project_id = data.google_project.project.id

  display_name          = each.value.display_name
  host                  = each.value.host
  path                  = each.value.path
  notification_channels = [google_monitoring_notification_channel.email.name]
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Tech"
  type         = "email"
  labels = {
    email_address = "tech@code.supply"
  }
}
