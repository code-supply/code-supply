variable "cluster_cidr_block" {
  default = "172.16.0.0/28"
}

variable "standard_node_tag" {
  default = "codesupplyk8s"
}

resource "google_compute_firewall" "permit_istio_master" {
  name    = "istio-master"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["15017"]
  }

  source_ranges = [var.cluster_cidr_block]
  target_tags   = [var.standard_node_tag]
}

resource "google_container_cluster" "belgium_pink" {
  provider = google-beta

  name     = "pink"
  location = "europe-west1-b"

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "REGULAR"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.cluster_cidr_block
  }

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = ""
    services_ipv4_cidr_block = ""
  }

  workload_identity_config {
    identity_namespace = "${data.google_project.project.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "belgium_d" {
  name       = "waffles"
  location   = "europe-west1-b"
  cluster    = google_container_cluster.belgium_pink.name
  node_count = 2

  node_config {
    preemptible  = true
    disk_size_gb = 10

    machine_type = "e2-medium"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/service.management",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    tags = [var.standard_node_tag]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
