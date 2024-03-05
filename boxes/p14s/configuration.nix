{
  imports = [
    ./boot.nix
    ../common/gui.nix
    ../common/locale.nix
    ../common/nix.nix
    ../common/user.nix
    ./gpg-ssh.nix
    ./hardware-configuration.nix
    ./network.nix
    ./sound.nix
  ];

  services.fwupd.enable = true;
  services.printing.enable = true;

  virtualisation.docker.enable = true;

  system.stateVersion = "22.11";
}
