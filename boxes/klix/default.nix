{
  nix,
  sops-nix,
  klixUrl,
  websites,
  ...
}:

{
  system = "aarch64-linux";
  modules = [
    sops-nix.nixosModules.sops
    (
      { config, ... }:
      {
        boot.growPartition = true;
        boot.loader.grub.configurationLimit = 5;
        sops.defaultSopsFile = ./secrets/klix.yaml;
        sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        services.openobserve = {
          enable = true;
          environmentFile = "${config.sops.secrets."openobserve/environment".path}";
        };
      }
    )
    ../common/locale.nix
    ../common/nix.nix
    ../common/openobserve.nix
    ../common/server-packages.nix
    ../common/user.nix
    ./configuration.nix
    ./klix.nix
    ../unhinged/caddy.nix
  ];
  specialArgs = {
    inherit
      nix
      websites
      klixUrl
      ;
  };
}
