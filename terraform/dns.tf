variable "cluster-ingress-address" {
  default = "35.195.27.167"
}

resource "google_dns_managed_zone" "root" {
  name     = "root-zone"
  dns_name = "code.supply."
}

resource "google_dns_record_set" "root" {
  name         = google_dns_managed_zone.root.dns_name
  managed_zone = google_dns_managed_zone.root.name
  rrdatas      = [google_compute_address.multi-vhost.address]
  ttl          = 1800
  type         = "A"
}

resource "google_dns_record_set" "www" {
  name         = "www.${google_dns_managed_zone.root.dns_name}"
  managed_zone = google_dns_managed_zone.root.name
  rrdatas      = [google_dns_managed_zone.root.dns_name]
  ttl          = 1800
  type         = "CNAME"
}

resource "google_dns_record_set" "mx" {
  name         = google_dns_managed_zone.root.dns_name
  managed_zone = google_dns_managed_zone.root.name
  rrdatas      = ["10 mail.protonmail.ch."]
  ttl          = 86400
  type         = "MX"
}

resource "google_dns_record_set" "txt" {
  name         = google_dns_managed_zone.root.dns_name
  managed_zone = google_dns_managed_zone.root.name

  rrdatas = [
    "\"protonmail-verification=02ca549762aa8bd67a2f875006a89f6f25062cb5\"",
    "\"v=spf1 include:_spf.protonmail.ch mx ~all\"",
    "\"google-site-verification=PCTBvbv7evH-3PiRZAfgZwBCVGJvKpWwGB3_6Wu5Tj4\"",
  ]

  ttl  = 21600
  type = "TXT"
}

resource "google_dns_record_set" "protonmail_dkim" {
  name         = "protonmail._domainkey.${google_dns_managed_zone.root.dns_name}"
  managed_zone = google_dns_managed_zone.root.name

  rrdatas = [
    "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCkvOv9oUqMfFIpZ/iazzFhDRY+g+pwgIdY7cjHHFRY2tXGCNJ+FttIxSKoKOK/8JJ0CtF6GrotboAnYgz+OuwKgNgnYuDqrVjehogEN83pAY4BxTut+vLUZEjYcQsanHdY6mW7hnefbBQ6yyl7pJwWqsgXG8ebHgBwXpNCEMKdnwIDAQAB\"",
  ]

  ttl  = 21600
  type = "TXT"
}

resource "google_dns_managed_zone" "ab" {
  name     = "andrewbruce-net"
  dns_name = "andrewbruce.net."
}

resource "google_dns_record_set" "ab-root" {
  name         = google_dns_managed_zone.ab.dns_name
  managed_zone = google_dns_managed_zone.ab.name
  rrdatas      = [google_compute_address.multi-vhost.address]
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "ab-www" {
  name         = "www.${google_dns_managed_zone.ab.dns_name}"
  managed_zone = google_dns_managed_zone.ab.name
  rrdatas      = [google_dns_record_set.ab-root.name]
  ttl          = 300
  type         = "CNAME"
}

resource "google_dns_record_set" "ab-wildcard" {
  name         = "*.${google_dns_managed_zone.ab.dns_name}"
  managed_zone = google_dns_managed_zone.ab.name
  rrdatas      = [var.cluster-ingress-address]
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "ab-mx" {
  name         = google_dns_managed_zone.ab.dns_name
  managed_zone = google_dns_managed_zone.ab.name
  rrdatas      = ["10 mail.protonmail.ch."]
  ttl          = 86400
  type         = "MX"
}

resource "google_dns_record_set" "ab-proton" {
  name         = google_dns_managed_zone.ab.dns_name
  managed_zone = google_dns_managed_zone.ab.name

  rrdatas = [
    "\"protonmail-verification=fe9c51b4c934c98b03be9cf1b9fb6c26a239c23c\"",
    "\"v=spf1 include:_spf.protonmail.ch mx ~all\"",
  ]

  ttl  = 21600
  type = "TXT"
}

resource "google_dns_record_set" "ab-dkim" {
  name         = "protonmail._domainkey.${google_dns_managed_zone.ab.dns_name}"
  managed_zone = google_dns_managed_zone.ab.name

  rrdatas = [
    "\"v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDFDjL8rc21ICQcjH+4rWBfCT8JO91/ejkcAFAfJPVSZtXCaADWs1Ft5d/o3G2/iFNklHh0piTRIBXcyTCTWsLS7+1/xRLtUH09ixGmgW8nD25PmMPkjYlFkW4vlR+oknHTvJpDVoO7w+uAM2SUoSTFVvNYc9NzS1Dd1zb24qxK7QIDAQAB\"",
  ]

  ttl  = 21600
  type = "TXT"
}

resource "google_dns_record_set" "ab-rdale" {
  name         = "rdale.${google_dns_managed_zone.ab.dns_name}"
  managed_zone = google_dns_managed_zone.ab.name

  rrdatas = ["81.187.237.24"]
  ttl     = 86400
  type    = "A"
}
