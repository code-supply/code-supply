resource "google_dns_managed_zone" "affable" {
  name     = "affable"
  dns_name = "affable.app."
}

resource "google_dns_record_set" "affable-root" {
  name         = google_dns_managed_zone.affable.dns_name
  managed_zone = google_dns_managed_zone.affable.name
  rrdatas      = [google_compute_address.multi-vhost.address]
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "affable-www" {
  name         = "www.${google_dns_managed_zone.affable.dns_name}"
  managed_zone = google_dns_managed_zone.affable.name
  rrdatas      = ["www.affable.app.gigalixirdns.com."]
  ttl          = 300
  type         = "CNAME"
}
