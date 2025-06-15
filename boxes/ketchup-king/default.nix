{
  isd,
  klix,
  ...
}:

{
  system = "aarch64-linux";
  modules = [
    ./3d-printing-server.nix
    ../common/user.nix
    ./network.nix
    klix.nixosModules.default
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
