resource "google_dns_managed_zone" "comparestuff" {
  name     = "comparestuff"
  dns_name = "comparestuff.co."
}

resource "google_dns_record_set" "comparestuff-root" {
  name         = google_dns_managed_zone.comparestuff.dns_name
  managed_zone = google_dns_managed_zone.comparestuff.name
  rrdatas      = [var.cluster-ingress-address]
  ttl          = 1800
  type         = "A"
}

resource "google_dns_record_set" "comparestuff-wildcard" {
  name         = "*.${google_dns_managed_zone.comparestuff.dns_name}"
  managed_zone = google_dns_managed_zone.comparestuff.name
  rrdatas      = [var.cluster-ingress-address]
  ttl          = 1800
  type         = "A"
}
