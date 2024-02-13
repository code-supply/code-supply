{ nixpkgs, system, websites, ... }:

nixpkgs.lib.nixosSystem {
  inherit system;

  modules = [
    ./configuration.nix
    ../common/locale.nix
    ../common/user.nix
    ./caddy.nix
    ./dnsmasq.nix
    ./hardware-configuration.nix
    ./network.nix
    ./nix.nix
    ./postgresql.nix
    ./tweaks.nix
  ];

  specialArgs =
    let
      prefix-ipv6 = "2001:8b0:b184:5567";
    in
    {
      inherit websites;
      router-ipv4 = "192.168.1.1";
      router-ipv6 = "${prefix-ipv6}::1";
      ipv4 = "192.168.1.182";
      ipv6 = "${prefix-ipv6}::2";
    };
}
