resource "google_compute_instance" "multi-vhost" {
  name         = "multi-vhost"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "multi-vhost"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.multi-vhost.address
    }
  }
}
