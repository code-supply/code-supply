{
  nix,
  system,
  websites,
  ...
}:

{
  inherit system;

  modules = [
    ./caddy.nix
    ../common/locale.nix
    ../common/nix.nix
    ../common/server-packages.nix
    ../common/server-tweaks.nix
    ../common/user.nix
    ./configuration.nix
    ./hardware-configuration.nix
    ./network.nix
    ({ nix.package = nix; })
    ./printers.nix
    ./tweaks.nix
  ];

  specialArgs =
    let
      prefix-ipv6 = "2001:8b0:b184:5567";
    in
    {
      inherit nix websites;
      router-ipv4 = "192.168.1.1";
      router-ipv6 = "${prefix-ipv6}::1";
      ipv4 = "192.168.1.182";
      ipv6 = "${prefix-ipv6}::2";
    };
}
