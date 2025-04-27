{
  nixpkgs,
  nixos-hardware,
  ...
}:

{
  system = "aarch64-linux";
  modules = [
    ./3d-printing-server.nix
    ../common/3d-printing-server.nix
    ../common/nix.nix
    ../common/ssh.nix
    ../common/user.nix
    ./network.nix
    ./rpi.nix
    nixos-hardware.nixosModules.raspberry-pi-4
    {
      system.stateVersion = "25.05";
      imports = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      ];
    }
  ];
}
