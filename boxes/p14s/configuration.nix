{
  imports = [
    ./boot.nix
    ../common/locale.nix
    ../common/user.nix
    ./gpg-ssh.nix
    ./gui.nix
    ./hardware-configuration.nix
    ./network.nix
    ./nix.nix
    ./sound.nix
  ];

  services.fwupd.enable = true;
  services.printing.enable = true;

  virtualisation.docker.enable = true;

  system.stateVersion = "22.11";
}
