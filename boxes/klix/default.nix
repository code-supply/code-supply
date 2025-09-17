{
  isd,
  nix,
  sops-nix,
  websites,
  ...
}:

{
  system = "aarch64-linux";
  modules = [
    sops-nix.nixosModules.sops
    {
      boot.growPartition = true;
      boot.loader.grub.configurationLimit = 5;
      sops.defaultSopsFile = ./secrets/klix.yaml;
      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    }
    ../common/locale.nix
    ../common/nix.nix
    ../common/server-packages.nix
    ./configuration.nix
    ./klix.nix
  ];
  specialArgs = {
    inherit isd nix websites;
  };
}
