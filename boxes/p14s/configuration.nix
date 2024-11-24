{
  imports = [
    ./boot.nix
    ../common/gui.nix
    ../common/locale.nix
    ../common/nix.nix
    ../common/steam.nix
    ../common/user.nix
    ./fonts.nix
    ./gpg-ssh.nix
    ./hardware-configuration.nix
    ./lid-switch.nix
    ./postgres.nix
    ./network.nix
    ./sound.nix
  ];

  nixpkgs.config.allowUnfree = true;
  services.fwupd.enable = true;
  services.printing.enable = true;
  system.stateVersion = "22.11";
  virtualisation.docker.enable = true;
}
