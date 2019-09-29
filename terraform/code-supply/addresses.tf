resource "google_compute_address" "istio-ingress-production" {
  name         = "istio-ingress-ip-production"
  address      = "35.189.105.191"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}
