resource "google_compute_router" "router" {
  name    = "router"
  region  = data.google_compute_subnetwork.default.region
  network = data.google_compute_network.default.self_link
}

resource "google_compute_address" "nat" {
  name   = "nat"
  region = data.google_compute_subnetwork.default.region
}

resource "google_compute_router_nat" "nat" {
  name   = "nat"
  router = google_compute_router.router.name
  region = google_compute_router.router.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat.*.self_link

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ALL"
  }
}

output "cloud-nat-ip" {
  value = google_compute_address.nat.address
}
