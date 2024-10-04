locals {
  main-ipv4-address     = "81.187.237.24"
  unhinged-ipv6-address = "2001:8b0:b184:5567::2"
}

resource "google_dns_managed_zone" "root" {
  name     = "root-zone"
  dns_name = "code.supply."
}

resource "google_dns_record_set" "root" {
  name         = google_dns_managed_zone.root.dns_name
  managed_zone = google_dns_managed_zone.root.name
  rrdatas      = [local.main-ipv4-address]
  ttl          = 86400
  type         = "A"
}

resource "google_dns_record_set" "root-ipv6" {
  name         = google_dns_managed_zone.root.dns_name
  managed_zone = google_dns_managed_zone.root.name
  rrdatas      = [local.unhinged-ipv6-address]
  ttl          = 86400
  type         = "AAAA"
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
    "protonmail.domainkey.dkhjnoxzm5gjd5wewoi5ay2shiaebhpqelfgvs4aiyr4tttpetjtq.domains.proton.ch.",
  ]

  ttl  = 21600
  type = "CNAME"
}

resource "google_dns_record_set" "protonmail_dkim2" {
  name         = "protonmail2._domainkey.${google_dns_managed_zone.root.dns_name}"
  managed_zone = google_dns_managed_zone.root.name

  rrdatas = [
    "protonmail2.domainkey.dkhjnoxzm5gjd5wewoi5ay2shiaebhpqelfgvs4aiyr4tttpetjtq.domains.proton.ch.",
  ]

  ttl  = 21600
  type = "CNAME"
}

resource "google_dns_record_set" "protonmail_dkim3" {
  name         = "protonmail3._domainkey.${google_dns_managed_zone.root.dns_name}"
  managed_zone = google_dns_managed_zone.root.name

  rrdatas = [
    "protonmail3.domainkey.dkhjnoxzm5gjd5wewoi5ay2shiaebhpqelfgvs4aiyr4tttpetjtq.domains.proton.ch.",
  ]

  ttl  = 60
  type = "CNAME"
}

resource "google_dns_managed_zone" "ab" {
  name     = "andrewbruce-net"
  dns_name = "andrewbruce.net."
}

resource "google_dns_record_set" "ab-root" {
  name         = google_dns_managed_zone.ab.dns_name
  managed_zone = google_dns_managed_zone.ab.name
  rrdatas      = [local.main-ipv4-address]
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "ab-root-ipv6" {
  name         = google_dns_managed_zone.ab.dns_name
  managed_zone = google_dns_managed_zone.ab.name
  rrdatas      = [local.unhinged-ipv6-address]
  ttl          = 300
  type         = "AAAA"
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
  rrdatas      = [local.main-ipv4-address]
  ttl          = 300
  type         = "A"
}

resource "google_dns_record_set" "ab-wildcard-ipv6" {
  name         = "*.${google_dns_managed_zone.ab.dns_name}"
  managed_zone = google_dns_managed_zone.ab.name
  rrdatas      = [local.unhinged-ipv6-address]
  ttl          = 300
  type         = "AAAA"
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
    "protonmail.domainkey.d52vvvwhtejhbugd3xqtpjghcqs5dv2qyptt7rbsbqykex7dob4xa.domains.proton.ch.",
  ]

  ttl  = 21600
  type = "CNAME"
}

resource "google_dns_record_set" "ab-dkim2" {
  name         = "protonmail2._domainkey.${google_dns_managed_zone.ab.dns_name}"
  managed_zone = google_dns_managed_zone.ab.name

  rrdatas = [
    "protonmail2.domainkey.d52vvvwhtejhbugd3xqtpjghcqs5dv2qyptt7rbsbqykex7dob4xa.domains.proton.ch.",
  ]

  ttl  = 21600
  type = "CNAME"
}

resource "google_dns_record_set" "ab-dkim3" {
  name         = "protonmail3._domainkey.${google_dns_managed_zone.ab.dns_name}"
  managed_zone = google_dns_managed_zone.ab.name

  rrdatas = [
    "protonmail3.domainkey.d52vvvwhtejhbugd3xqtpjghcqs5dv2qyptt7rbsbqykex7dob4xa.domains.proton.ch.",
  ]

  ttl  = 21600
  type = "CNAME"
}

resource "google_dns_record_set" "ab-main" {
  name         = "main.${google_dns_managed_zone.ab.dns_name}"
  managed_zone = google_dns_managed_zone.ab.name

  rrdatas = [local.main-ipv4-address]
  ttl     = 86400
  type    = "A"
}

resource "google_dns_record_set" "ab-main-ipv6" {
  name         = "main.${google_dns_managed_zone.ab.dns_name}"
  managed_zone = google_dns_managed_zone.ab.name

  rrdatas = [local.unhinged-ipv6-address]
  ttl     = 600
  type    = "AAAA"
}
