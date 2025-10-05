resource "hcloud_server" "klix" {
  name = "klix"
  image = "ubuntu-24.04"
  server_type = "cax41"

  shutdown_before_deletion = true

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
