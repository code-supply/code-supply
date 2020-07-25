resource "google_dns_managed_zone" "affable" {
  name     = "affable"
  dns_name = "affable.app."
}

resource "google_dns_record_set" "affable-root" {
  name         = google_dns_managed_zone.affable.dns_name
  managed_zone = google_dns_managed_zone.affable.name
  rrdatas      = ["35.195.27.167"]
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "affable-www" {
  name         = "www.${google_dns_managed_zone.affable.dns_name}"
  managed_zone = google_dns_managed_zone.affable.name
  rrdatas      = [google_dns_record_set.affable-root.name]
  ttl          = 300
  type         = "CNAME"
}
