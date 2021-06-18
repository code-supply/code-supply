resource "google_compute_url_map" "http-redirect" {
  name = "web-map-http"

  default_url_redirect {
    strip_query            = false
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
  }
}

resource "google_compute_target_http_proxy" "http-redirect" {
  name    = "web-map-http-target-proxy"
  url_map = google_compute_url_map.http-redirect.id
}

resource "google_compute_global_forwarding_rule" "http-redirect" {
  name       = "http-content-rule"
  ip_address = google_compute_global_address.affable.address
  target     = google_compute_target_http_proxy.http-redirect.id
  port_range = "80"
}
