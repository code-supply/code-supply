{ pkgs, ... }:
{
  imports = [
    ./boot.nix
    ../common/gpg-ssh.nix
    ../common/gui.nix
    ../common/locale.nix
    ../common/nix.nix
    ../common/server-packages.nix
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
  services.printing = {
    enable = true;
    drivers = [ pkgs.samsung-unified-linux-driver ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  system.stateVersion = "22.11";
  virtualisation.docker.enable = true;
}
