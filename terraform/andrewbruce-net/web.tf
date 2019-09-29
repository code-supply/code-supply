resource "google_compute_address" "web" {
  name = "web"
}

resource "google_compute_firewall" "web" {
  name    = "web"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = ["web"]
}

resource "google_compute_instance" "web" {
  name         = "web"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.web.address
    }
  }
}

resource "google_storage_bucket" "web_backup" {
  name = "andrewbruce-web-backup"
}

resource "google_storage_bucket_iam_binding" "web_backup" {
  bucket = google_storage_bucket.web_backup.name
  role   = "roles/storage.objectCreator"

  members = [
    "serviceAccount:900215636127-compute@developer.gserviceaccount.com",
  ]
}
