{
  isd,
  nixos-hardware,
  klix,
  ...
}:

{
  system = "aarch64-linux";
  modules = [
    ./3d-printing-server.nix
    ../common/user.nix
    ./network.nix
    nixos-hardware.nixosModules.raspberry-pi-4
    klix.nixosModules.default
    ./rpi.nix
    {
      nixpkgs.overlays = [
        (final: prev: {
          isd = isd.packages.aarch64-linux.default;
        })
      ];
      time.timeZone = "Europe/London";
      system.stateVersion = "25.05";
    }
  ];
}
