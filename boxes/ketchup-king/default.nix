{
  nixpkgs,
  ...
}:

{
  system = "x86_64-linux";
  modules = [
    ../common/user.nix
    ../common/ssh.nix
    ./3d-printing-server.nix
    {
      imports = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      ];
      nixpkgs.crossSystem = {
        system = "aarch64-linux";
      };
      disabledModules = [
        "profiles/all-hardware.nix"
        "profiles/base.nix"
      ];
      networking = {
        firewall.enable = false;
        hostName = "ketchup-king";
        wireless.enable = true;
      };
      security.sudo.wheelNeedsPassword = false;
    }
  ];
}
