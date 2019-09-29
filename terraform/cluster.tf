data "google_container_cluster" "code-supply" {
  name     = "code-supply-zonal"
  location = "europe-west2-b"
}

resource "google_container_node_pool" "pooly" {
  provider = google
  name     = "pooly"
  location = "europe-west2-b"
  cluster  = data.google_container_cluster.code-supply.name
  version  = "1.13.7-gke.8"

  node_config {
    preemptible = true

    metadata = {
      disable-legacy-endpoints = "true"
    }

    disk_size_gb = 10
    machine_type = "n1-standard-1"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/service.management",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
