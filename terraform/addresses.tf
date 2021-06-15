resource "google_compute_address" "multi-vhost" {
  name         = "multi-vhost"
  address_type = "EXTERNAL"
  region       = "us-east1"
}

resource "google_compute_global_address" "affable" {
  name = "affable"
}
