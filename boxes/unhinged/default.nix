{
  isd,
  nix,
  sops-nix,
  system,
  websites,
  ...
}:

{
  inherit system;

  modules = [
    {
      sops.defaultSopsFile = ./secrets/klix.yaml;
      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    }
    ./caddy.nix
    ../common/locale.nix
    ../common/nix.nix
    ../common/server-packages.nix
    ../common/server-tweaks.nix
    ../common/user.nix
    ./configuration.nix
    ./hardware-configuration.nix
    ./klix.nix
    ./network.nix
    ({ nix.package = nix; })
    ./printers.nix
    sops-nix.nixosModules.sops
    ./tweaks.nix
  ];

  specialArgs =
    let
      prefix-ipv6 = "2001:8b0:b184:5567";
    in
    {
      inherit isd nix websites;
      router-ipv4 = "192.168.1.1";
      router-ipv6 = "${prefix-ipv6}::1";
      ipv4 = "192.168.1.182";
      ipv6 = "${prefix-ipv6}::2";
    };
}
