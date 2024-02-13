{ ipv4
, ipv6
, ...
}:

{
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--cluster-cidr=10.42.0.0/16,fd42::/56"
      "--service-cidr=10.43.0.0/16,fd43::/112"
      "--node-ip=${ipv4},${ipv6}"
    ];
  };
}
