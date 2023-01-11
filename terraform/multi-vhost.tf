resource "google_compute_firewall" "web" {
  name    = "web"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = ["web"]
}

resource "google_compute_firewall" "ssh" {
  name    = "ssh"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ssh"]
}
