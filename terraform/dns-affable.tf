resource "google_dns_managed_zone" "affable" {
  name     = "affable"
  dns_name = "affable.app."
}

resource "google_dns_record_set" "affable-root" {
  name         = google_dns_managed_zone.affable.dns_name
  managed_zone = google_dns_managed_zone.affable.name
  rrdatas      = [var.cluster-ingress-address]
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "affable-wildcard" {
  name         = "*.${google_dns_managed_zone.affable.dns_name}"
  managed_zone = google_dns_managed_zone.affable.name
  rrdatas      = [var.cluster-ingress-address]
  ttl          = 1800
  type         = "A"
}

resource "google_dns_record_set" "affable-images" {
  name         = "images.${google_dns_managed_zone.affable.dns_name}"
  managed_zone = google_dns_managed_zone.affable.name
  rrdatas      = [google_compute_global_address.affable.address]
  ttl          = 1800
  type         = "A"
}
