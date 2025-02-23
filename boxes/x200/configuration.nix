{ pkgs, ... }:

{
  imports = [
    ./3d-printing-server.nix
    ./boot.nix
    ../common/locale.nix
    ../common/server-nix.nix
    ../common/server-tweaks.nix
    ../common/user.nix
    ./hardware-configuration.nix
    ./network.nix
  ];

  environment.systemPackages = with pkgs; [
    lsof
  ];

  system.stateVersion = "24.11";
}
