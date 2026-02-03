{ pkgs, ... }:
{
  imports = [
    ./boot.nix
    ../common/gui.nix
    ../common/locale.nix
    ../common/nix.nix
    ../common/openobserve.nix
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

  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;
  nix.buildMachines = [
    {
      hostName = "klix.code.supply";
      system = "aarch64-linux";
      supportedFeatures = [
        "kvm"
        "nixos-test"
        "big-parallel"
      ];
      maxJobs = 15;
    }
  ];

  system.stateVersion = "22.11";

  virtualisation.docker.enable = true;

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    fwupd.enable = true;

    gnome.gcr-ssh-agent.enable = false;

    openobserve.enable = true;

    pcscd.enable = true;

    printing = {
      enable = true;
      drivers = [ pkgs.samsung-unified-linux-driver ];
    };
  };

  programs.ssh = {
    startAgent = true;
    agentPKCS11Whitelist = "*libykcs11.so*";
  };
}
