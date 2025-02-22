{ pkgs, ... }:

{
  imports = [
    ./3d-printing-server.nix
    ../common/locale.nix
    ../common/server-nix.nix
    ../common/user.nix
    ./hardware-configuration.nix
    ./network.nix
  ];

  environment.systemPackages = with pkgs; [
    lsof
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";

  system.stateVersion = "24.11";
}
