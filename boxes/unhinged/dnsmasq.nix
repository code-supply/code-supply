{ ipv4
, ipv6
, ...
}:

{
  services.resolved.enable = false;
  services.dnsmasq = {
    enable = true;
    settings = {
      no-hosts = true;
      no-resolv = true;
      no-poll = true;
      address = [
        "/*.code.test/127.0.0.1"
        "/*.code.supply/${ipv4}"
        "/*.code.supply/${ipv6}"
        "/unhinged/${ipv4}"
        "/unhinged/${ipv6}"
      ];
      server = [
        "8.8.8.8"
        "8.8.4.4"
        "2001:4860:4860::8888"
        "2001:4860:4860::8844"
      ];
    };
  };
}
