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

  networking.wireless.enable = true;
  networking.wireless.secretsFile = "/run/secrets/wireless.conf";
  networking.wireless.networks.vegetables2ghz = {
    pskRaw = "ext:psk_vegetables2ghz";
    extraConfig = ''
      ssid="Vegetables 2Ghz"
    '';
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  system.stateVersion = "24.11";
}
