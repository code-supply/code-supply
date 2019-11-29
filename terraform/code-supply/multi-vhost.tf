resource "google_compute_instance" "multi-vhost" {
  name         = "multi-vhost"
  machine_type = "f1-micro"
  zone         = "us-east1-b"
  tags         = ["web"]

  boot_disk {
    initialize_params {
      image = "multi-vhost-1575025152"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.multi-vhost.address
    }
  }

  service_account {
    email = google_service_account.certbot-dns.email
    scopes = [
      "cloud-platform",
    ]
  }
}

resource "google_compute_firewall" "web" {
  name    = "web"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = ["web"]
}
