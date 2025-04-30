{
  nixpkgs,
  nixos-hardware,
  ...
}:

{
  system = "aarch64-linux";
  modules = [
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ./3d-printing-server.nix
    ../common/3d-printing-server.nix
    ../common/nix.nix
    ../common/ssh.nix
    ../common/user.nix
    ./network.nix
    nixos-hardware.nixosModules.raspberry-pi-4
    ./rpi.nix
    {
      time.timeZone = "Europe/London";
      system.stateVersion = "25.05";
    }
  ];
}
