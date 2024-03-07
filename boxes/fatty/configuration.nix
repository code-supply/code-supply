{ pkgs, ... }:

{
  imports =
    [
      ../common/gui.nix
      ../common/locale.nix
      ../common/nix.nix
      ../common/user.nix
      ./hardware-configuration.nix
      ./nvidia.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-6077d9e7-633c-485f-b3f1-2eb7b93f5983".device = "/dev/disk/by-uuid/6077d9e7-633c-485f-b3f1-2eb7b93f5983";
  networking.hostName = "fatty";

  networking.networkmanager.enable = true;

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  programs.ssh.startAgent = false;

  system.stateVersion = "23.05";
}
