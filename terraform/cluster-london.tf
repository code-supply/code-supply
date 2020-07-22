resource "google_container_cluster" "london_pink" {
  provider = google-beta

  name     = "pink"
  location = "europe-west2-c"

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR"
  }

  addons_config {
    istio_config {
      disabled = false
    }
  }
}

resource "google_container_node_pool" "london_c" {
  name       = "london-reliable"
  location   = "europe-west2-c"
  cluster    = google_container_cluster.london_pink.name
  node_count = 1

  node_config {
    machine_type = "g1-small"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/service.management",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
