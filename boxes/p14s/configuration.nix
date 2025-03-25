{
  imports = [
    ./boot.nix
    ../common/gpg-ssh.nix
    ../common/gui.nix
    ../common/locale.nix
    ../common/server-nix.nix
    ../common/steam.nix
    ../common/user.nix
    ./fonts.nix
    ./hardware-configuration.nix
    ./lid-switch.nix
    ./network.nix
    ./postgres.nix
    ./sound.nix
  ];

  nixpkgs.config.allowUnfree = true;
  services.fwupd.enable = true;
  services.printing.enable = true;
  system.stateVersion = "22.11";
  virtualisation.docker.enable = true;
}
