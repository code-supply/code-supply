resource "google_dns_managed_zone" "root" {
  name     = "root-zone"
  dns_name = "andrewbruce.net."
}

resource "google_dns_record_set" "mx" {
  name         = google_dns_managed_zone.root.dns_name
  managed_zone = google_dns_managed_zone.root.name
  rrdatas      = ["10 mail.protonmail.ch."]
  ttl          = 86400
  type         = "MX"
}

resource "google_dns_record_set" "dkim" {
  name         = "protonmail._domainkey.${google_dns_managed_zone.root.dns_name}"
  managed_zone = google_dns_managed_zone.root.name

  rrdatas = [
    "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDFDjL8rc21ICQcjH+4rWBfCT8JO91/ejkcAFAfJPVSZtXCaADWs1Ft5d/o3G2/iFNklHh0piTRIBXcyTCTWsLS7+1/xRLtUH09ixGmgW8nD25PmMPkjYlFkW4vlR+oknHTvJpDVoO7w+uAM2SUoSTFVvNYc9NzS1Dd1zb24qxK7QIDAQAB\"",
  ]

  ttl  = 21600
  type = "TXT"
}

resource "google_dns_record_set" "root" {
  name         = google_dns_managed_zone.root.dns_name
  managed_zone = google_dns_managed_zone.root.name
  rrdatas      = [google_compute_address.web.address]
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "www" {
  name         = "www.${google_dns_managed_zone.root.dns_name}"
  managed_zone = google_dns_managed_zone.root.name
  rrdatas      = [google_dns_managed_zone.root.dns_name]
  ttl          = 300
  type         = "CNAME"
}

resource "google_dns_record_set" "txt" {
  name         = google_dns_managed_zone.root.dns_name
  managed_zone = google_dns_managed_zone.root.name

  rrdatas = [
    "\"protonmail-verification=fe9c51b4c934c98b03be9cf1b9fb6c26a239c23c\"",
    "\"v=spf1 include:_spf.protonmail.ch mx ~all\"",
  ]

  ttl  = 21600
  type = "TXT"
}

