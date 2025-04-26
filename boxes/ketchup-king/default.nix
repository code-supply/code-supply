{
  nixpkgs,
  ...
}:

{
  system = "x86_64-linux";
  modules = [
    ../common/server-nix.nix
    ../common/ssh.nix
    ../common/user.nix
    ./3d-printing-server.nix
    ./network.nix
    ./rpi.nix
    {
      imports = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      ];
      nixpkgs.crossSystem.system = "aarch64-linux";
    }
  ];
}
